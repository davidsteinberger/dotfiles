(ns local.dev.kotlin
  "Helpers for Kotlin classes. Needs kotlin-reflect on the classpath.")

(defn- ->class
  "Converts any object into a java.lang.Class."
  [x]
  (if (class? x) x (class x)))

(defn constructor-params
  "Returns the primary constructor parameters of a Kotlin class (data classes
  included) as [{:name :type :optional?}], in declaration order, or nil for
  anything else. Java reflection only has arg0, arg1, ... for these, the names
  and defaults come from the Kotlin metadata."
  [x]
  (try
    (let [kc (kotlin.jvm.JvmClassMappingKt/getKotlinClass (->class x))]
      (when-let [ctor (kotlin.reflect.full.KClasses/getPrimaryConstructor kc)]
        (mapv (fn [^kotlin.reflect.KParameter p]
                {:name      (.getName p)
                 :type      (str (.getType p))
                 :optional? (.isOptional p)})
              (.getParameters ctor))))
    (catch Throwable _ nil)))

(defn data-class?
  "True if x (a class or an object) is a Kotlin data class."
  [x]
  (try
    (.isData (kotlin.jvm.JvmClassMappingKt/getKotlinClass (->class x)))
    (catch Throwable _ false)))

(defn construct
  "Constructs an instance of a Kotlin class from its primary constructor, with
  only the given arguments set. Parameters left out get their Kotlin default
  value, which plain Java interop cannot do. `args` is a map of parameter
  name (keyword or string) to value, see constructor-params for the names.
  (kotlin/construct TemplateConfiguration {:localDirectory \"/tmp\"})"
  [clazz args]
  (let [kc     (kotlin.jvm.JvmClassMappingKt/getKotlinClass clazz)
        ctor   (kotlin.reflect.full.KClasses/getPrimaryConstructor kc)
        params (into {} (map (fn [^kotlin.reflect.KParameter p] [(.getName p) p]))
                     (.getParameters ctor))
        args   (update-keys args name)]
    (when-let [unknown (seq (remove params (keys args)))]
      (throw (ex-info (str "No such constructor parameter(s) on " (.getName ^Class clazz))
                      {:unknown (vec unknown) :valid (vec (keys params))})))
    (.callBy ctor (reduce-kv (fn [m k v] (assoc m (params k) v)) {} args))))
