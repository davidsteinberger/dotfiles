(ns interop-stress
  "Stress cases for the conjure_blink completion source.
  Type the member prefix at the `|` and check the menu against the comment.
  Connect first: clj -M:dev:nrepl, then :ConjureConnect."
  (:import (java.io File)
           (java.nio.file Files Path Paths)
           (java.time Duration Instant LocalDate ZoneId)
           (java.util ArrayList HashMap UUID)))

(comment
  ;; ---- Should narrow to the right class (lookup by reflection) ----------

  ;; static -> instance. UUID members: .toString .version .getMostSignificantBits
  (.ver| (UUID/randomUUID))

  ;; constructor -> instance. ArrayList members: .add .addAll .ensureCapacity
  (.ens| (ArrayList. 10))
  (.ens| (java.util.ArrayList.))

  ;; 2-step chain. UUID -> String members: .toUpperCase .substring .chars
  (.toUp| (.toString (UUID/randomUUID)))

  ;; 3-step chain. Instant -> ZonedDateTime -> LocalDate members
  (.lengthOfM| (.toLocalDate (.atZone (Instant/now) (ZoneId/of "UTC"))))

  ;; primitive return -> boxed. `.toEpochMilli` is long -> Long members (.longValue)
  (.longV| (.toEpochMilli (Instant/now)))

  ;; `.length` is int -> Integer members (.intValue .compareTo)
  (.intV| (.length "abc"))

  ;; no space before the inner form
  (.plusD|(LocalDate/now 5))
  (.getPa|(Path/of "/tmp"))

  ;; static method with overloads that all return one type (Paths/get -> Path)
  (.getFileN| (Paths/get "/tmp" (into-array String [])))

  ;; ---- Should still work via hints, not reflection ------------------------

  (let [^Instant t (Instant/now)]
    (.minusS| t 5))

  (defn file-name [^File f]
    (.getNa| f))

  ;; evaluate first (<localleader>ee), then complete on the var
  (def home (File. (System/getProperty "user.home")))
  (.listF| home)

  ;; ---- Static members (no hint needed) ------------------------------------

  (Instant/ofE| 0)
  (Duration/ofMi| 5)
  (UUID/fromS| "x")
  (Files/readAllL| (Path/of "/tmp/x"))
  (Character/isLetterOrD| \a)
  java.time.ZoneId/sys|

  ;; ---- Known gaps: expect the generic list, not an error -------------------

  ;; unhinted local
  (let [t (Instant/now)]
    (.plusS| t 5))

  ;; result of a Clojure fn / threading macro
  (.getNa| (first [(File. "/tmp")]))
  (-> (Instant/now) (.toEpochM|))
  (doto (ArrayList.) (.ad| 1))

  ;; return type depends on overloads (Files/newBufferedReader is unambiguous,
  ;; Files/walk returns Stream; Files/lines also Stream) - check these too
  (.coun| (Files/lines (Path/of "/tmp/x")))

  ;; target on the next line is not inspected
  (.getNa|
   (File. "/tmp"))

  ;; case-insensitive fuzzy matching: all should offer .toEpochMilli
  (.toepo| (Instant/now))
  (.TOEPOCH| (Instant/now))
  (.tEM| (Instant/now)))
