(ns local.dev.spy
  "Debug helpers for map/filter/reduce pipelines and transducers.")

(defmacro spy
  "Print label (or the quoted form) and its value, then return the value.
  Threads with -> and ->> via (spy :label). Realizes lazy seqs when printing."
  ([form] `(spy nil ~form))
  ([label form]
   `(let [v# ~form]
      (binding [*print-length* 10]
        (println (str (or ~label '~form) " =>") (pr-str v#)))
      v#)))

(defn spy-xf
  "Transducer that prints each input (and completion) and passes it through.
  Optional f maps the input before printing."
  ([label] (spy-xf label identity))
  ([label f]
   (fn [rf]
     (fn
       ([] (rf))
       ([result] (println label "complete") (rf result))
       ([result input]
        (println label (pr-str (f input)))
        (rf result input))))))

(defn spy-rf
  "Wrap a reducing fn to print acc, input and the new acc on every step."
  [label rf]
  (fn
    ([] (rf))
    ([acc] (println label "done" (pr-str acc)) (rf acc))
    ([acc x]
     (let [acc' (rf acc x)]
       (println label (pr-str acc) "+" (pr-str x) "=>" (pr-str acc'))
       acc'))))

(comment
  ;; spy in a ->> pipeline: label first, form arrives last
  (->> (range 10)
       (map inc)
       (spy :after-map)
       (filter odd?)
       (spy :after-filter)
       (reduce +))
  ;; :after-map => (1 2 3 4 5 6 7 8 9 10)
  ;; :after-filter => (1 3 5 7 9)
  ;; => 25

  ;; spy without a label prints the quoted form
  (spy (map inc [1 2 3]))
  ;; (map inc [1 2 3]) => (2 3 4)

  ;; spy in a -> pipeline: the threaded value is the form, so use the 1-arity.
  ;; The unlabeled print shows the previous step's expanded form.
  (-> {:a 1}
      (assoc :b 2)
      (spy)
      (update :a inc))
  ;; (assoc {:a 1} :b 2) => {:a 1, :b 2}
  ;; => {:a 2, :b 2}

  ;; spy inside a let
  (let [xs (spy :xs (filter even? (range 100)))]
    (count xs))
  ;; :xs => (0 2 4 6 8 10 12 14 16 18 ...)
  ;; => 50
  ;; Only the printout is truncated (*print-length* is bound to 10 in spy);
  ;; xs itself still has all 50 elements.

  ;; spy-xf: elements move through the stages one at a time
  (into []
        (comp (map inc)
              (spy-xf :after-inc)
              (filter odd?)
              (spy-xf :after-odd))
        (range 5))
  ;; :after-inc 1
  ;; :after-odd 1
  ;; :after-inc 2
  ;; :after-inc 3
  ;; :after-odd 3
  ;; ...
  ;; :after-inc complete
  ;; :after-odd complete
  ;; => [1 3 5]

  ;; spy-xf with a print fn: show only the id of each map
  (into []
        (comp (spy-xf :users :id)
              (filter :active?))
        [{:id 1 :active? true :blob "..."} {:id 2 :active? false :blob "..."}])

  ;; spy-xf shows early termination and the completion flush
  (into []
        (comp (spy-xf :before-take)
              (take 2)
              (spy-xf :after-take))
        (range 100))
  ;; stops after 2 items; no 100-element walk

  ;; stateful stage: completion arity flushes the partial chunk
  (into []
        (comp (partition-all 2)
              (spy-xf :chunk))
        (range 5))
  ;; :chunk [0 1]
  ;; :chunk [2 3]
  ;; :chunk [4]
  ;; :chunk complete

  ;; spy-rf in plain reduce
  (reduce (spy-rf :sum +) 0 [1 2 3])
  ;; :sum 0 + 1 => 1
  ;; :sum 1 + 2 => 3
  ;; :sum 3 + 3 => 6
  ;; => 6

  ;; spy-rf with transduce: wrap the final reducing fn, see what reaches it
  (transduce (comp (map inc) (filter odd?))
             (spy-rf :sink conj)
             []
             (range 5))
  ;; :sink [] + 1 => [1]
  ;; :sink [1] + 3 => [1 3]
  ;; :sink [1 3] + 5 => [1 3 5]
  ;; :sink done [1 3 5]

  ;; Variant: send values to tap> instead of stdout (watch in Portal/Reveal)
  (add-tap #(println "tap:" (pr-str %)))
  (into [] (comp (map inc) (map #(doto % tap>))) (range 3))
  )
