;; dart-doc.el --- Show documentation for Dart using the Dart Analysis Server

;; Author: Henrik Jegbjerg Hansen
;; Version: 0.01
;; Package-Requires: ((dart-mode "0.14") (markdown-mode)

(require 'dart-mode)
(require 'markdown-mode)

(defvar dart-doc--buffer
  (generate-new-buffer "*dart-doc*"))

(defun dart-doc ()
  "Ask the analysis server for documentation."
  (interactive)

  (dart--analysis-server-send
   "analysis.getHover"
   `((file . ,(buffer-file-name (current-buffer)))
     (offset . ,(point)))
   'dart-doc--display))

(defun dart-doc--display (response)
  "Parse and display documentation if available."
  (let* ((hovers (cdr (assoc 'hovers (cdr (assoc 'result response)))))
         (hover (if (>= (length hovers) 1) (elt hovers 0) nil))
         (no-doc-message "No documentation available."))
    (if hover
        (let* ((element-description (cdr (assoc 'elementDescription hover)))
               (dartdoc (cdr (assoc 'dartdoc hover)))
               (doc (if (= (length element-description) 0)
                        nil
                      (if (= (length dartdoc) 0)
                          element-description
                        (concat element-description "\n\n" dartdoc))))
               (x-gtk-use-system-tooltips nil))
          (if doc
              (progn
                (dart-doc--markdown element-description dartdoc))
            (message no-doc-message)))
      (message no-doc-message))))

(defun dart-doc--markdown (element-description dartdoc)
  "Display parsed documentation in a Markdown-buffer."
  ;; (display-buffer-below-selected dart-doc--buffer nil)
  (with-current-buffer dart-doc--buffer
    (funcall 'markdown-mode)
    (erase-buffer)
    (let ((dartdoc-available (> (length dartdoc) 0))
          (window (get-buffer-window (current-buffer))))
      (when (> (length element-description) 0)
        (insert (concat "# " element-description))
        (when dartdoc-available
          (insert "\n\n")))
      (when dartdoc-available
        (insert dartdoc))
      (display-buffer (current-buffer)))))
      ;; (maximize-window window)
      ;; (shrink-window-if-larger-than-buffer window))))

(provide 'dart-doc)
     
 
