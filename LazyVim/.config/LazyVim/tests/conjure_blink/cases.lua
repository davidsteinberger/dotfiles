-- Each case: code with `|` marking the cursor (end of the typed word).
--   class   every reflected item must come from this class
--   has     labels that must be offered
--   lacks   labels that must not be offered
--   detail  { label = "substring expected in the item's signature" }
--   generic the case must fall back to plain nREPL completion (no reflected items)
--   e2e     run through blink.cmp with fuzzy matching; `first` is the expected top label
local NS = [[(ns t
  (:require [clojure.string :as str])
  (:import (java.io File) (java.nio.file Paths Path) (java.time Duration Instant LocalDate ZoneId)
           (java.time.temporal ChronoUnit) (java.util ArrayList UUID)))
]]

local INSTANT = "java.time.Instant"

return {
  -- setup evaluated in the REPL before the cases run (user ns)
  setup = {
    [[(def home (java.io.File. "/tmp"))]],
    [[(defn now ^java.time.Instant [] (java.time.Instant/now))]],
  },

  cases = {
    -- ---- type hints -------------------------------------------------------
    { name = "hinted let local", code = NS .. [[(let [^Instant t (Instant/now)] (.minusS| t 5))]],
      class = INSTANT, has = { ".minusSeconds" }, lacks = { ".getId", ".getName" } },
    { name = "hinted fn param", code = NS .. [[(defn f [^File f] (.getNa| f))]],
      class = "java.io.File", has = { ".getName" }, lacks = { ".getId" } },
    { name = "hinted multi-arity fn param", code = NS .. [[(fn ([^File f] (.getPa| f)) ([a b] a))]],
      class = "java.io.File", has = { ".getParent" } },
    { name = "hint on the target form", code = NS .. [[(.plusS| ^Instant (foo) 1)]],
      class = INSTANT, has = { ".plusSeconds" } },
    { name = "primitive hint is boxed", code = NS .. [[(defn f [^long n] (.intV| n))]],
      class = "java.lang.Long", has = { ".intValue" } },

    -- ---- call expressions -------------------------------------------------
    { name = "static call", code = NS .. [[(.toEpochM| (Instant/parse "2026-10-02T10:00:00.000Z"))]],
      class = INSTANT, has = { ".toEpochMilli" }, lacks = { ".getId" } },
    { name = "static call, no space", code = NS .. [[(.plusD|(LocalDate/now))]],
      class = "java.time.LocalDate", has = { ".plusDays" } },
    { name = "static overloads with one return type", code = NS .. [[(.getFileN| (Paths/get "/tmp" (into-array String [])))]],
      class = "java.nio.file.Path", has = { ".getFileName" } },
    { name = "constructor", code = NS .. [[(.ens| (ArrayList. 10))]],
      class = "java.util.ArrayList", has = { ".ensureCapacity" } },
    { name = "fully qualified constructor", code = NS .. [[(.ens| (java.util.ArrayList.))]],
      class = "java.util.ArrayList", has = { ".ensureCapacity" } },
    { name = "new form", code = NS .. [[(.ens| (new ArrayList 10))]],
      class = "java.util.ArrayList", has = { ".ensureCapacity" } },
    { name = "two-step chain", code = NS .. [[(.toUp| (.toString (UUID/randomUUID)))]],
      class = "java.lang.String", has = { ".toUpperCase" } },
    { name = "three-step chain", code = NS .. [[(.lengthOfM| (.toLocalDate (.atZone (Instant/now) (ZoneId/of "UTC"))))]],
      class = "java.time.LocalDate", has = { ".lengthOfMonth" } },
    { name = "primitive return is boxed", code = NS .. [[(.longV| (.toEpochMilli (Instant/now)))]],
      class = "java.lang.Long", has = { ".longValue" }, lacks = { ".getId" } },
    { name = "int return is boxed", code = NS .. [[(.intV| (.length "abc"))]],
      class = "java.lang.Integer", has = { ".intValue" } },
    { name = "multi-line target", code = NS .. "(.toEpochM|\n  (Instant/parse\n    \"2026-10-02T10:00:00.000Z\"))",
      class = INSTANT, has = { ".toEpochMilli" } },
    { name = "parens in strings and comments", code = NS .. "(.toEpochM| (Instant/parse \"((( ;\" ) ; )))\n)",
      class = INSTANT, has = { ".toEpochMilli" } },
    { name = "discarded form is ignored", code = NS .. [[(.toEpochM| #_(foo) (Instant/parse "x"))]],
      class = INSTANT, has = { ".toEpochMilli" } },

    -- ---- locals -----------------------------------------------------------
    { name = "unhinted let local", code = NS .. [[(let [t (Instant/now)] (.plusS| t 5))]],
      class = INSTANT, has = { ".plusSeconds" } },
    { name = "let local from a chain", code = NS .. [[(let [a (Instant/now) b (.atZone a (ZoneId/of "UTC"))] (.toLocalD| b))]],
      class = "java.time.ZonedDateTime", has = { ".toLocalDate" } },
    { name = "shadowed let local", code = NS .. [[(let [t "x" t (Instant/now)] (.plusS| t 1))]],
      class = INSTANT, has = { ".plusSeconds" } },
    { name = "with-open local", code = NS .. [[(with-open [r (clojure.java.io/reader "/tmp/x")] (.readL| r))]],
      class = "java.io.BufferedReader", has = { ".readLine" } },

    -- ---- literals, core fns, vars ----------------------------------------
    { name = "string literal", code = NS .. [[(.toUpperC| "abc")]],
      class = "java.lang.String", has = { ".toUpperCase" } },
    { name = "keyword literal", code = NS .. [[(.getNa| :foo)]],
      class = "clojure.lang.Keyword", has = { ".getName" } },
    { name = "str returns a String", code = NS .. [[(.toUpperC| (str 1 2))]],
      class = "java.lang.String", has = { ".toUpperCase" } },
    { name = "aliased clojure.string fn", code = NS .. [[(.toUpperC| (str/trim " a "))]],
      class = "java.lang.String", has = { ".toUpperCase" } },
    { name = "def'd var (evaluated)", code = NS .. [[(.listF| home)]],
      class = "java.io.File", has = { ".listFiles" } },
    { name = "fn with return hint", code = NS .. [[(.plusS| (now) 1)]],
      class = INSTANT, has = { ".plusSeconds" } },

    -- ---- macros that thread a receiver -------------------------------------
    { name = "-> step", code = NS .. [[(-> (Instant/now) (.atZone (ZoneId/of "UTC")) (.toLocalD|))]],
      class = "java.time.ZonedDateTime", has = { ".toLocalDate" } },
    { name = "-> bare step", code = NS .. [[(-> (Instant/now) .atZone (.toLocalD|))]],
      class = "java.time.ZonedDateTime", has = { ".toLocalDate" } },
    { name = "-> bare completion", code = NS .. [[(-> (Instant/now) .atZ|)]],
      class = INSTANT, has = { ".atZone" } },
    { name = "some->", code = NS .. [[(some-> (Instant/now) (.atZone (ZoneId/of "UTC")) (.toLocalD|))]],
      class = "java.time.ZonedDateTime", has = { ".toLocalDate" } },
    { name = "->> zero-arg instance step", code = NS .. [[(->> (Instant/now) (.toEpochMilli) (.longV|))]],
      class = "java.lang.Long", has = { ".longValue" } },
    { name = "->> step completion", code = NS .. [[(->> (Instant/now) (.toEpochM|))]],
      class = INSTANT, has = { ".toEpochMilli" } },
    { name = "->> bare step", code = NS .. [[(->> (Instant/now) .toEpochMilli (.longV|))]],
      class = "java.lang.Long", has = { ".longValue" } },
    { name = "->> step with explicit receiver", code = NS .. [[(->> "abc" (.app| (StringBuilder.)))]],
      class = "java.lang.StringBuilder", has = { ".append" } },
    { name = "doto", code = NS .. [[(doto (ArrayList.) (.ad| 1))]],
      class = "java.util.ArrayList", has = { ".add", ".addAll" } },
    { name = ".. chain", code = NS .. [[(.. (Instant/now) (atZone (ZoneId/of "UTC")) toLocalD|)]],
      class = "java.time.ZonedDateTime", has = { "toLocalDate" }, lacks = { ".toLocalDate" } },
    { name = ".. chain, sublist step", code = NS .. [[(.. (Instant/now) (atZone (ZoneId/of "UTC")) (toLocalD|))]],
      class = "java.time.ZonedDateTime", has = { "toLocalDate" } },
    { name = "(. target member)", code = NS .. [[(. (Instant/now) toEpochM|)]],
      class = INSTANT, has = { "toEpochMilli" }, lacks = { ".toEpochMilli" } },
    { name = "(. Class member)", code = NS .. [[(. Instant no|)]],
      class = INSTANT, has = { "now", "ofEpochSecond" }, lacks = { "toEpochMilli" } },

    -- ---- fields and statics ------------------------------------------------
    { name = "instance field (.-f)", code = NS .. [[(.-x| (java.awt.Point. 1 2))]],
      class = "java.awt.Point", has = { ".-x", ".-y" }, lacks = { ".toString" } },
    { name = "static methods", code = NS .. [[(Instant/ofE|)]],
      class = INSTANT, has = { "Instant/ofEpochSecond" }, lacks = { "Instant/toEpochMilli" } },
    { name = "static methods, fq class", code = NS .. [[(java.time.ZoneId/sys|)]],
      class = "java.time.ZoneId", has = { "java.time.ZoneId/systemDefault" } },
    { name = "static field", code = NS .. [[(identity Instant/EPO|)]],
      class = INSTANT, has = { "Instant/EPOCH" } },

    -- ---- signatures --------------------------------------------------------
    { name = "signature shown for the matching arity",
      code = NS .. [[(.plus| (Instant/now) 1 ChronoUnit/DAYS)]],
      class = INSTANT, detail = { [".plus"] = "long, TemporalUnit" } },

    -- ---- fallbacks ---------------------------------------------------------
    { name = "unknown receiver falls back", code = NS .. [[(.getNa| (first [1]))]], generic = true },
    { name = "clojure fns still complete", code = NS .. [[(clojure.string/joi|)]], generic = true, has = { "clojure.string/join" } },

    -- ---- end to end through blink.cmp (fuzzy, case-insensitive) --------------
    { name = "e2e: .toepo finds .toEpochMilli", e2e = true, first = ".toEpochMilli",
      code = NS .. [[(.toepo| (Instant/parse "2026-10-02T10:00:00.000Z"))]], lacks = { ".getId" } },
    { name = "e2e: .TOEPOCH finds .toEpochMilli", e2e = true, first = ".toEpochMilli",
      code = NS .. [[(.TOEPOCH| (Instant/now))]] },
  },
}
