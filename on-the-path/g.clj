#!/usr/bin/env clj-ng
#_(comment (defenv clj-env
           (:dependencies [[mcp-core "1.0.0-SNAPSHOT"]])))
(import '(java.io File)
        '(java.util.regex Pattern))
(use '[mcp-core.sh])
(use '[clojure.contrib.command-line :only [with-command-line print-help]])
(require '[clojure.java.io :as io])
(require '[clojure.string :as string])

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Utilities
;;

(def commands {})
(def *tmp* (io/file (System/getProperty "java.io.tmpdir")))
(def *repository-search-depth* 3)
(def *ansi* true)

(defn ansi
  [attributes]
  (if *ansi*
    (str (char 033)
         (condp = attributes
             :red "[31m"
             :gray "[37m"
             :off "[0m"))
    ""))

(defn clean-branch-name
  [s]
  (re-find #"[^ *]+" s))

(defn lines-to-list
  ([s] (lines-to-list s true))
  ([s trim]
     (filter #(not (empty? %))
             (map #(if (not (or (= :no-trim trim)
                                (not trim)))
                     (string/trim %)
                     %)
                  (string/split-lines s)))))

(defn fail-if-exists
  [f]
  (when (.exists f)
    (throw (RuntimeException. (str f " already exists!")))))

(defn fail-if-not-exists
  [f]
  (when-not (.exists f)
    (throw (RuntimeException. (str f " already exists!"))))
  f)

(defn mkdirs
  [dir]
  (fail-if-not-exists
   (doto (io/file dir)
     .mkdirs)))

(defn uniquified-temp-dir
  [name]
  (loop [counter 0]
    (when (> counter 1000)
      (throw (RuntimeException. (str "Couldn't find an unused directory name (" name ")"))))
    (let [dir (io/file *tmp* (str name "-" counter))]
      (if-not (.exists dir)
        (mkdirs dir)
        (recur (inc counter))))))

(defn list-all-branches
  []
  (map clean-branch-name (lines-to-list ($> git branch -a))))

(defn get-current-branch
  []
  (when-let [line (first (filter #(re-find #"^[*]" %)
                                 (string/split-lines ($> git branch))))]
    (clean-branch-name line)))

(defn find-repositories
  ([] (find-repositories ($>-n pwd) *repository-search-depth*))
  ([dir depth]
     (let [cwd (io/file dir)]
       (if (.isDirectory (io/file cwd ".git"))
         [cwd]
         (when (> depth 0)
           (mapcat #(find-repositories % (dec depth))
                   (filter #(.isDirectory %) (.listFiles cwd))))))))

(defmacro defcommand
  [cmd doc args & body]
  (let [command-sym (symbol (str (name cmd) "-command"))]
    `(do
       (defn ~command-sym [& ~'args]
         (try
          (with-command-line
            ~'args
            ~doc
            ~args
            ~@body)
          (catch Exception e# (.printStackTrace e#))))
       (alter-var-root #'commands
                       (fn [x#] (assoc x# ~(name cmd) (var ~command-sym)))))))

(defn maybe-add-color-option
  [command args]
  (if (and (#{"diff"} command)
           (not-any? #(re-find #"^--color=" %) args))
    (cons "--color=always" args)
    args))

(defn spit-bytes
  [f content & opts]
  (with-open [^java.io.OutputStream o (apply io/output-stream f opts)]
    (.write o content)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Core functions
;;

(defn diff
  [orig new & options]
  (let [cwd ($>-n pwd)]
    (when-not (.exists (io/file cwd ".git"))
      (throw (RuntimeException. "Must be run from repository root.")))
    (let [options (apply hash-map options)
          paths (filter #(not (empty? %))
                        (lines-to-list ($> git diff --name-only --find-renames ~orig ~new)))
          root-dir (uniquified-temp-dir "diff")
          orig-dir (mkdirs (io/file root-dir "orig"))
          new-dir (mkdirs (io/file root-dir "new"))
          manifest (io/file root-dir (str (.getName (io/file cwd)) "-" (string/replace new #"[^A-Za-z0-9]""_") "-diff.org"))]
      (when-not (empty? paths)
        (when (and (:in-place-current options) (not= (get-current-branch) new))
          (throw (RuntimeException. (format "Must have checked out %s." new))))
        (when (and (:in-place-current options) (not (:ignore-uncommitted options)))
          (when-not (empty? ($>-n git status -s))
            (throw (RuntimeException. "Working dir is not clean."))))
        (spit manifest "#    -*- mode: org; comment-start: nil; org-confirm-elisp-link-function: nil -*-\n")
        (doseq [path paths]
          (let [orig-file (io/file orig-dir path)
                new-file (io/file (if (:in-place-current options) cwd new-dir) path)
                {orig-file-data :out exit-code :exit err :err} ($raw>? git show ~(str orig ":" path))]
            (when (= 0 exit-code)
              (mkdirs (.getParentFile orig-file))
              (spit-bytes orig-file orig-file-data))
            (when-not (:in-place-current options)
              (let [{new-file-data :out exit-code :exit err :err} ($raw>? git show ~(str new ":" path))]
                (when (= 0 exit-code)
                  (mkdirs (.getParentFile new-file))
                  (spit-bytes new-file new-file-data))))
            (spit manifest (if (.exists orig-file)
                             (format "[[elisp:(ediff-files \"%s\" \"%s\")][%s %s]]\n"
                                     orig-file
                                     new-file
                                     (if (.exists new-file) "   " "---")
                                     path)
                             (format "[[file:%s][+++ %s]]\n"
                                     new-file
                                     path))
                  :append true)))
        ($? emacsclient -n ~(str manifest))))))

(defn diff-local
  [& specific-paths]
  (let [cwd ($>-n pwd)]
    (when-not (.exists (io/file cwd ".git"))
      (throw (RuntimeException. "Must be run from repository root.")))
    (let [orig "HEAD"
          paths (filter #(not (empty? %))
                        (lines-to-list ($> git diff --name-only --find-renames ~orig -- ~@specific-paths)))
          root-dir (uniquified-temp-dir "diff")
          orig-dir (mkdirs (io/file root-dir "orig"))
          manifest (io/file root-dir (str (.getName (io/file cwd)) "-working-diff.org"))]
      (when-not (empty? paths)
        (spit manifest "#    -*- mode: org; comment-start: nil; org-confirm-elisp-link-function: nil -*-\n")
        (doseq [path paths]
          (let [orig-file (io/file orig-dir path)
                new-file (io/file cwd path)
                {orig-file-data :out exit-code :exit err :err} ($raw>? git show ~(str orig ":" path))]
            (when (= 0 exit-code)
              (mkdirs (.getParentFile orig-file))
              (spit-bytes orig-file orig-file-data))
            (spit manifest (if (.exists orig-file)
                             (format "[[elisp:(ediff-files \"%s\" \"%s\")][%s %s]]\n"
                                     orig-file
                                     new-file
                                     (if (.exists new-file) "   " "---")
                                     path)
                             (format "[[file:%s][+++ %s]]\n"
                                     new-file
                                     path))
                  :append true)))
        ($? emacsclient -n ~(str manifest))))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Commands
;;

;; 2015-05-15 bstiles: Re-implemented as Git alias.
;; (defcommand ediff
;;   "Diff the working files against HEAD using ediff."
;;   [specific-paths]
;;   (apply diff-local specific-paths))

(defcommand review-branch
  "Generate an mini-program for running ediff on the changes in a branch."
  [[parent "Parent branch (mutually exclusive with child branch)"]
   [child "Child branch (mutually exclusive with parent branch)"]
   [continue? "Continue even if uncommitted files exist"]]
  (cond
   parent (let [current-branch (get-current-branch)]
            (when (= current-branch "(no")
              (println "!! Not on a branch !!"))
            (diff ($>-n git merge-base ~parent ~current-branch)
                  current-branch
                  :ignore-uncommitted continue?
                  :in-place-current true))
   child (let [current-branch (get-current-branch)]
           (when (= current-branch "(no")
             (println "!! Not on a branch !!"))
           (diff ($>-n git merge-base ~current-branch ~child)
                 child
                 :ignore-uncommitted continue?
                 :in-place-current false))
   :else (recur ["--help"])))

(defcommand mergetool
  "Reminder that mergetool must be run via git, directly."
  []
  (println "mergetool must be run via git, directly!"))

(defcommand difftool
  "Reminder that difftool must be run via git, directly."
  []
  (println "difftool must be run via git, directly!"))

(defcommand current-branch
  "Display the name of the current branch."
  []
  (println (get-current-branch)))

(defcommand branches
  "Show the divergence between specified branches."
  [[d "Display divergence from the specified branch."]
   [r "Remote to focus on (use . for local)."]
   [b "Branch to focus on."]
   unknown]
  (when-not (empty? unknown)
    (throw (RuntimeException. (pr-str unknown))))
  (let [remotes-filter (Pattern/compile
                        (apply str
                               "^ *"
                               (if r
                                 (if (= "." r)
                                   "(?!remotes/)"
                                   (str "remotes/" r))
                                 (interpose
                                  "|"
                                  (concat
                                   ["(?!remotes/)"]
                                   (map #(str "remotes/" %)
                                        (string/split-lines ($> git remote))))))))
        branches-filter (Pattern/compile
                         (if b
                           (str "^" b "$")
                           ".*"))
        branches (reduce
                  (fn [coll [k v]] (assoc coll k (conj (get coll k []) v)))
                  {}
                  (map (fn [x]
                         (if-let [match (re-find #"remotes/([^/]*)/(.*)" x)]
                           [(nth match 1) (nth match 2)]
                           ["." x]))
                       (filter #(re-find branches-filter
                                         (re-find #"[^/]+$" %))
                               (filter #(re-find remotes-filter %)
                                       (list-all-branches)))))
        current-branch (get-current-branch)]
    (when d
      (println "Divergence from" d))
    (doseq [remote (sort (keys branches))]
      (println (format "%s%s%s" (ansi :red) remote (ansi :off)))
      (doseq [branch (branches remote)]
        (let [branch-full-name (if (= "." remote)
                                 (clean-branch-name branch)
                                 (str remote "/" branch))
              branch-is-current-branch (= current-branch branch-full-name)]
          (if d
            (let [divergence-from-specified
                  (count
                   (lines-to-list
                    ($> git log --oneline ~(str d ".." branch-full-name))))
                  divergence-of-specified
                  (count
                   (lines-to-list
                    ($> git log --oneline ~(str branch-full-name ".." d))))]
              (println (format "%4s  %s%4s %s%s"
                               (if (= 0 divergence-of-specified)
                                 ""
                                 divergence-of-specified)
                               (cond
                                (and (not= 0 divergence-of-specified)
                                     (not= 0 divergence-from-specified))
                                "-"
                                :else " ")
                               (if (= 0 divergence-from-specified)
                                 ""
                                 divergence-from-specified)
                               (if branch-is-current-branch "* " "  ")
                               branch)))
            (println (format "%s%s" (if branch-is-current-branch "* " "  ") branch))))))))

;; (defcommand rebase-on-trunk
;;   []
;;   (if-not (empty? (lines-to-list ($> git status --porcelain)))
;;     (println "Outstanding changes exist. Not safe to rebase.")
;;     (let [current-branch (get-current-branch)]
;;       (and
;;        (= 0 ($? git checkout trunk-transfer))
;;        (= 0 ($? git svn rebase))
;;        (= 0 ($? git checkout master))
;;        (= 0 ($? git rebase trunk-transfer))
;;        (= 0 ($? git checkout develop))
;;        (= 0 ($? git rebase master)))
;;       ($ git checkout ~current-branch))))

;; 2015-05-15 bstiles: Re-implemented as Git alias
;; (defcommand lb
;;   "Show log of changes (via 'lg' command) on the current branch since
;;   it branched from its upstream. (Same as git log upstream..)"
;;   [branches]
;;   (when (< 1 (count branches))
;;     (throw (RuntimeException. "Only a single (or no) branch specification is supported!")))
;;   (let [branch (if (empty? branches) (get-current-branch) (first branches))
;;         upstream ($>-n git for-each-ref
;;                        "--format=%(upstream:short)"
;;                        ~(format "refs/heads/%s" branch))]
;;     (if (empty? upstream)
;;       (println "Can't determine upstream!")
;;       ($ g lg -1000 ~(str upstream ".." branch)))))

;; 2015-05-15 bstiles: Re-implemented as Git alias
;; (defcommand lu
;;   "Show log of changes (via 'lg' command) on the remote branch since
;;   it branched from the current branch. (Same as git log ..upstream)"
;;   [branches]
;;   (when (< 1 (count branches))
;;     (throw (RuntimeException. "Only a single (or no) branch specification is supported!")))
;;   (let [branch (if (empty? branches) (get-current-branch) (first branches))
;;         upstream ($>-n git for-each-ref
;;                        "--format=%(upstream:short)"
;;                        ~(format "refs/heads/%s" branch))]
;;     (if (empty? upstream)
;;       (println "Can't determine upstream!")
;;       ($ g lg -1000 ~(str branch ".." upstream)))))

(defcommand us
  "Show the divergence between each branch and its upstream."
  []
  (let [lines (lines-to-list ($> g branch -vv) :no-trim)]
    (doseq [line lines
            :let [[_ marker branch remote ahead behind]
                  (re-find #"([ *] )(\S+)\s+\S+ (?:\[([^:\]]+)(?:: ahead ([0-9]+))?(?:[,:] behind ([0-9]+))?)?" line)]]
      (println (format "%4s  %s%4s %s%-25s%s"
                       (or behind "")
                       (if (and behind ahead)
                         "-"
                         " ")
                       (or ahead "")
                       marker
                       branch
                       (if remote (format " [%s]" remote) ""))))))

(defn fs
  [fork-name]
  (let [fork fork-name
        branches (map #(re-find #"([ *]{2})(.*)" %)
                      (lines-to-list ($> g branch) :no-trim))]
    (doseq [[_ marker branch] branches]
      (let [behind-fork
            (let [{:keys [exit out]} ($>? git log --oneline ~(str branch ".." fork "/" branch))]
              (when (zero? exit)
                (count (lines-to-list out))))
            ahead-of-fork
            (let [{:keys [exit out]} ($>? git log --oneline ~(str fork "/" branch ".." branch))]
              (when (zero? exit)
                (count (lines-to-list out))))]
        (println (format "%4s  %s%4s %s%-25s%s"
                         (cond
                          (nil? behind-fork) "n/a"
                          (pos? behind-fork) behind-fork
                          :else "")
                         (if (and behind-fork (pos? behind-fork) (pos? ahead-of-fork))
                           "-"
                           " ")
                         (cond
                          (nil? ahead-of-fork) ""
                          (pos? ahead-of-fork) ahead-of-fork
                          :else "")
                         marker
                         branch
                         (if (nil? behind-fork)
                           ""
                           (format " [%s/%s]" fork branch))))))))

(defcommand is
  "Show the divergence between each branch and irise/*."
  []
  (fs "irise"))

(defcommand fs
  "Show the divergence between each branch and my fork."
  []
  (fs "brianatirise"))

(defcommand dot
  "Generate a DOT file (Graphviz) representing the branch structure
  of up to the last 100 commits. (Operates on all branches if none
  are specified."
  [[limit l "Log limit (defaults to 100)."]
   branches]
  (let [limit (or limit "100")
        branches (if (empty? branches) "--all" branches)]
    (println "digraph history {")
    (println "rankdir=BT")
    (println "node [shape=record, style=rounded]")
    (let [n (atom 0)]
      (letfn [(next-node [] (str "_" (swap! n inc)))
              (edge [parent child & attributes]
                (str
                 (format "\"%s\"->\"%s\"" parent child)
                 (when attributes
                   (format " [%s]" (apply str
                                          (interpose
                                           ","
                                           (map #(apply format "%s=\"%s\"" %)
                                                (partition 2 attributes))))))))]
        (doseq [[_ decorations hash parents author subject]
                (re-seq
                 #"(?:\(([^)]+)\) )?([a-fA-F0-9]+) \[([^]]*)\] \[(.*)\] (.*)"
                 (:out ($>? git log ~(str "-" limit) "--pretty=format:%d %h [%p] [%an] %s" ~@branches)))
                :let [tags (map second (re-seq #"([^,]+)(?:, )?"
                                               (str decorations)))
                      parents (string/split (str parents) #" ")]]
          ;; Tags
          (when (not-empty tags)
            (let [tags-by-side (group-by #(re-find #"/" %) tags)]
              ;; Remote
              (when-let [tags (tags-by-side "/")]
                (let [tags-node (next-node)]
                  (println (format "\"%s\" [label=\"%s\",style=\"filled\",fillcolor=\"orange\"]"
                                   tags-node
                                   (apply str (interpose " | " tags))))
                  (println (edge tags-node hash "arrowhead" "none"))
                  (println (format "subgraph { rank=same \"%s\" \"%s\" }" hash tags-node))))
              ;; Local
              (when-let [tags (tags-by-side nil)]
                (let [tags-node (next-node)]
                  (println (format "\"%s\" [label=\"%s\",style=\"filled\",fillcolor=\"%s\"]"
                                   tags-node
                                   (apply str (interpose " | " tags))
                                   (if ((set tags) "HEAD") "green" "cyan")))
                  (println (edge hash tags-node "arrowhead" "none"))
                  (println (format "subgraph { rank=same \"%s\" \"%s\" }" hash tags-node))))))
          ;; Commit
          (println (format "\"%s\" [label=\"%s\\l\"]"
                           hash
                           (-> (apply str (interpose
                                           "\\l"
                                           [(format "%-20.20s"
                                                    (string/replace subject "\"" ""))
                                            hash
                                            author]))
                               (string/replace "<" "&lt;")
                               (string/replace ">" "&gt;")
                               (string/replace " " "&nbsp;"))))
          ;; Parents
          (doseq [p parents]
            (when (not-empty p)
              (println (edge p hash)))))))
    (println "}")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Main execution
;;

(defcommand tasting
  "Tasting."
  [[limit l "l"]
   b]
  (prn limit)
  (prn b))

(let [args *command-line-args*
      no-ansi (= "--no-ansi" (first args))
      args (if no-ansi
             (next args)
             args)
      substitute (= "--substitute" (first args))
      args (if substitute
             (next args)
             args)
      no-substitute (= "--no-substitute" (first args))
      args (if no-substitute
             (next args)
             args)
      [repositories
       command
       args]
      (condp = (.getName (io/file *file*))
        "g" [[($>-n pwd)]
             (first args)
             (next args)]
        ;; 2015-05-15 bstiles: Re-implemented as Git alias
#_#_        "gr" [(find-repositories)
              (first args)
              (next args)]
        ;; 2015-05-15 bstiles: Re-implemented as Git alias
#_#_        "gin" (if (= "[" (first args))
                (loop [repositories [] command nil args (next args)]
                  (if (or (empty? args) (= "]" (first args)))
                    [repositories (second args) (nnext args)]
                    (recur (conj repositories
                                 (.getPath (io/file ($>-n pwd)
                                                    (first args))))
                           nil
                           (next args))))
                [[(.getPath (io/file ($>-n pwd) (first args)))]
                 (second args)
                 (nnext args)]))
      args (maybe-add-color-option command args)]
  (when (and substitute no-substitute)
    (throw (IllegalArgumentException. "Can't specify --substitute and --no-substitute together.")))
  ;; Check for possible substitutions when the --substitute flag isn't specified
  (when (and (not substitute)
             (not no-substitute)
             (some #(re-find #"\Q${repo_name}\E" %) args))
    (throw (RuntimeException. "Looks like you're trying to use substitutions without --substitute.")))
  (if (= command "--help")
    (doseq [[command-name command-fn] (map #(vector % (get commands %)) (sort (keys commands)))]
      (println "Usage: " command-name)
      (let [s (with-out-str
                (command-fn "--help"))]
        (if-let [m (re-matches #"(?s:(.*\s+)Options)" (string/trimr s))]
          (println (m 1))
          (println s))))
    (doseq [repository repositories]
      (try
        ($pushd repository)
        (when no-ansi
          (alter-var-root #'*ansi* (fn [_] false)))
        (when (> (count repositories) 1)
          (print (ansi :gray))
          (println " _______________________________________________________________________________")
          (println (format "/ DO: git status IN: ./%s"
                           (str
                            (ansi :red)
                            (.getName (io/file ($>-n pwd)))
                            (ansi :gray))))
          (println "|")
          (print (ansi :off)))
      
        (let [args (if substitute
                     (map #(string/replace % #"\Q${repo_name}\E" (.getName (io/file repository))) args)
                     args)]
          (if-let [command-fn (get commands command)]
            (apply command-fn args)
            (eval `($ "git" ~command ~@args))))
        (catch Exception e (.printStackTrace e))
        (finally
         ($popd)
         (alter-var-root #'*ansi* (fn [_] true)))))))

;; Call $exit when not using nailgun
;;($exit)

;; Local Variables:
;; mode: clojure
;; End:
