(ns local.dev.introspect
  (:require [clojure.reflect :as cr]
            [clojure.string :as s]))
;
; Copyright © 2023 Peter Monks
;
; This Source Code Form is subject to the terms of the Mozilla Public
; License, v. 2.0. If a copy of the MPL was not distributed with this
; file, You can obtain one at https://mozilla.org/MPL/2.0/.
;
; SPDX-License-Identifier: MPL-2.0
;

(defn- object->class
  "Converts any object into a java.lang.Class."
  [obj]
  (cond
    (class?  obj) obj
; Note: Treating symbols as Java classes makes it impossible to introspect on
;       Clojure's symbol class itself.
;    (symbol? obj) (let [ns   (or (namespace obj) "java.lang")
;                      name (name obj)]
;                  (Class/forName (str ns "." name)))
    :else       (class obj)))

(defn- type->string
  "Converts a Java object or class (including things like primitive arrays) to a
  human readable, idiomatic Clojure string."
  [t]
  (when t
    (cr/typename (if (= java.lang.Class (class t))
                   t
                   (object->class t)))))

(defn- member-type->string
  "Converts a member type (e.g. its :type or one of its :parameter-types) to a
  human readable, idiomatic Clojure string."
  [t]
  (if (or (nil? t) (= "void" (str t)))
    "nil"
    (s/replace (str t) "<>" "[]")))

(defn- params->string
  "Converts the parameter types of a member to a human readable, idiomatic
  Clojure string."
  [params]
  (if params
    (s/join " " (map member-type->string params))
    "nil"))

(defmulti ^:private member->string
  "Returns a human-readable, idiomatic Clojure string representation of the
  given member contained within the given class or object (e.g. returned from
  clojure.reflect/reflect)."
  (fn [_ m] (class m)))

(defn- constructor-param-names
  "Returns the parameter names of the constructor of x whose parameter types
  match `param-types` (as in clojure.reflect), or nil when the class was not
  compiled with javac -parameters (reflection only knows arg0, arg1, ... then)."
  [x param-types]
  (let [types (map str param-types)]
    (some (fn [^java.lang.reflect.Constructor c]
            (let [ps (.getParameters c)]
              (when (and (= types (map #(cr/typename (.getType ^java.lang.reflect.Parameter %)) ps))
                         (every? #(.isNamePresent ^java.lang.reflect.Parameter %) ps))
                (mapv #(.getName ^java.lang.reflect.Parameter %) ps))))
          (.getDeclaredConstructors ^Class (object->class x)))))

(defmethod member->string clojure.reflect.Constructor
  [x m]
  (let [tn (type->string x)]
    (when (= tn (str (:declaring-class m)))    ; Constructors are not inherited in Java, yet they show up in the results of cr/reflect, so we filter them out.
      (let [types (map member-type->string (:parameter-types m))
            names (constructor-param-names x (:parameter-types m))
            params (if names
                     (map #(str %1 ":" %2) names types)   ; name:type when javac -parameters was used
                     types)]
        (str (when-not (contains? (:flags m) :public) "<non-public> ")
             "(" tn "."
             (when (seq params) (str " " (s/join " " params)))
             ") => " tn)))))   ; Java constructors have an implicit return type of the type itself - just make it explicit as that's closer to how they're used in Clojure

(defmethod member->string clojure.reflect.Method
  [x m]
  (let [tn (type->string x)]
    (str (when-not (contains? (:flags m) :public) "<non-public> ")
         "("
         (if (contains? (:flags m) :static)
           (str tn "/")
           ".")
         (:name m)
         (let [params (str " "
                           (s/join " " (concat (when-not (contains? (:flags m) :static) [tn])
                                               (map member-type->string (:parameter-types m)))))]   ; We don't use params->string here as we want the collection
           (when-not (s/blank? params) params))
         ") => " (member-type->string (:return-type m)))))

(defmethod member->string clojure.reflect.Field
  [x m]
  (let [tn (type->string x)]
    (str
     (when-not (contains? (:flags m) :public) "<non-public> ")
     (if (contains? (:flags m) :static)
       (str tn "/" (:name m) " => " (:type m))
       (str "(.-" (:name m) " " tn ") => " (:type m))))))

(defn- member-sort
  "Function for use in sort-by with Java members."
  [m]
  (when m
    (str (if (contains? (:flags m) :public) "0" "1")
         "-"
         (if (contains? (:flags m) :static) "0" "1")
         "-"
         (condp = (class m)    ; Note: case doesn't work property with class literals - see https://stackoverflow.com/questions/12028944/clojure-case-statement-with-classes
           clojure.reflect.Field       "0"
           clojure.reflect.Constructor "1"
           clojure.reflect.Method      "2")
         "-"
         (:name m)
         "-"
         (str (count (:parameter-types m)))
         "-"
         (params->string (:parameter-types m)))))

(defn- kotlin-fn
  "Resolves a var in local.dev.kotlin, or nil when kotlin-reflect is not on
  the classpath (that namespace fails to load without it)."
  [sym]
  (try
    (requiring-resolve (symbol "local.dev.kotlin" (name sym)))
    (catch Throwable _ nil)))

(defn- kotlin-constructor->string
  "Human-readable primary constructor of a Kotlin class with parameter names,
  types and whether they have a default value, or nil (also when kotlin-reflect
  is not available)."
  [x]
  (when-let [params (some-> (kotlin-fn 'constructor-params) (apply [x]) not-empty)]
    (let [clazz (object->class x)]
      (str "Kotlin primary constructor"
           (when ((kotlin-fn 'data-class?) clazz) " (data class)")
           ":\n(" (type->string clazz) "."
           (apply str (for [{:keys [name type optional?]} params]
                        (str "\n  " name " " type (when optional? " ; has default"))))
           "\n)"))))

(defn members
  "Returns a human-readable string representation of all of the Java members
  (constructors, methods, fields) in the given class or object, including those
  inherited from superclasses, as semi-idiomatic Clojure code. Defaults to
  public members only, add {:public-only false} to get all."
  [x & {public-only :public-only :or {public-only true}}]
  (when x
    (let [clazz (object->class x)]
      (->> (cr/reflect clazz :ancestors true)
           :members
           (filter #(not (contains? (:flags %) :synthetic)))  ; Remove synthetic (compiler-inserted) members
           (filter #(or (not public-only) (contains? (:flags %) :public)))
           (sort-by member-sort)
           (map (partial member->string clazz))
           distinct
           (filter #(not (s/blank? %)))
           (s/join "\n")
           (#(if-let [k (kotlin-constructor->string clazz)]
               (str % "\n\n" k)
               %))))))

(defn constructors
  "Returns a human-readable string of just the constructors of the given class
  or object: every Java constructor (with parameter names where the class was
  compiled with javac -parameters), followed by the Kotlin primary constructor
  with names and defaults if it is a Kotlin class. Defaults to public
  constructors only, add {:public-only false} to get all."
  [x & {public-only :public-only :or {public-only true}}]
  (when x
    (let [clazz (object->class x)]
      (->> (cr/reflect clazz)
           :members
           (filter #(instance? clojure.reflect.Constructor %))
           (filter #(not (contains? (:flags %) :synthetic)))  ; Remove synthetic (compiler-inserted) members
           (filter #(or (not public-only) (contains? (:flags %) :public)))
           (sort-by member-sort)
           (map (partial member->string clazz))
           (filter #(not (s/blank? %)))
           (s/join "\n")
           (#(if-let [k (kotlin-constructor->string clazz)]
               (str % "\n\n" k)
               %))))))

(defn print-constructors
  "Prints the constructors of the given class or object, see constructors."
  [x & {public-only :public-only :or {public-only true}}]
  (when x
    (let [clazz (object->class x)]
      (println (str (type->string clazz) " constructors:\n"))
      (println (constructors clazz {:public-only public-only})))))

(defn print-members
  "Prints to stdout a human-readable string representation of all of the Java
  members (constructors, methods, fields) in the given class or object,
  including those inherited from superclasses, as semi-idiomatic Clojure code.
  Defaults to public members only, add {:public-only false} to get all."
  [x & {public-only :public-only :or {public-only true}}]
  (when x
    (let [clazz (object->class x)]
      (println "--------------------")
      (println (str (when-not (= java.lang.Class (class x)) (str "\"" x "\" of type "))
                    (type->string clazz)
                    " has these"
                    (when public-only " public")
                    " Java members:\n"))
      (println (members clazz {:public-only public-only})))))
