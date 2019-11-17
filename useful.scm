;;; -*- coding: utf-8 -*-
;;; Copyright © 2019 Lewis Weinberger <lhw28@cam.ac.uk>
;;;
;;; This program is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License as
;;; published by the Free Software Foundation; either version 3 of the
;;; License, or (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see
;;; <http://www.gnu.org/licenses/>.

(define-module (useful)
  #:use-module (haunt html)
  #:use-module (haunt reader)
  #:use-module (haunt utils)
  #:use-module (haunt asset)
  #:use-module (haunt builder blog)
  #:use-module (haunt page)
  #:use-module (haunt post)
  #:use-module (haunt site)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-19)
  #:use-module (web uri)
  #:use-module (ice-9 match)
  #:use-module (sxml match)
  #:use-module (sxml transform)
  #:use-module (commonmark)
  #:export (link
	    default-theme
	    static-page
	    research-posts
	    misc-posts
	    centered-image
	    commonmark-reader*
	    date))


;;; HTML utilities ---------------------------------------------------


(define (link name uri)
  "Create a link with NAME to url URI."
  `(a (@ (href ,uri)
	 (class "w3-hover-opacity"))
      ,name))

(define (nav-button name uri)
  "Create a navigation button with NAME, that points to URI."
  `(a (@ (class "w3-bar-item w3-button w3-text-black w3-mobile w3-large")
	 (href ,uri))
      ,name))

(define (stylesheet name)
  "Use the stylesheet NAME.css saved locally in css/."
  `(link (@ (rel "stylesheet")
            (href ,(string-append "/css/" name ".css")))))

(define (external-stylesheet uri)
  "Use an external stylesheet from URI."
  `(link (@ (rel "stylesheet")
            (href ,uri))))

;; CC button
(define %cc-by-sa-button
  '(a (@ (class "cc-button")
         (href "https://creativecommons.org/licenses/by-sa/4.0/"))
      (img (@ (src "https://licensebuttons.net/l/by-sa/4.0/80x15.png")
	      (class "w3-hover-opacity")))))

;; Github button
(define %github-button
  '(a (@ (href "https://github.com/lewis-weinberger"))
      (i (@ (class "fa fa-github w3-hover-opacity w3-padding-small")))))

;; Bitbucket button
(define %bitbucket-button
  '(a (@ (href "https://bitbucket.org/lweinberger/"))
      (i (@ (class "fa fa-bitbucket w3-hover-opacity w3-padding-small")))))

;; LinkedIn button
(define %linkedin-button
  '(a (@ (href "https://www.linkedin.com/in/lewis-weinberger-119923194"))
      (i (@ (class "fa fa-linkedin w3-hover-opacity w3-padding-small")))))

;; ORC-ID button
(define %orcid-button
  '(a (@ (href "https://orcid.org/0000-0002-7312-4595"))
      (i (@ (class "ai ai-orcid w3-hover-opacity w3-padding-small")))))

;; Arxiv button
(define %arxiv-button
  '(a (@ (href "https://arxiv.org/search/?searchtype=author&query=Weinberger%2C+L+H"))
      (i (@ (class "ai ai-arxiv w3-hover-opacity w3-padding-small")))))

;; ADS button
(define %ads-button
  '(a (@ (href "https://ui.adsabs.harvard.edu/search/q=author%3A%22Weinberger%2C%20Lewis%20H.%22"))
      (i (@ (class "ai ai-ads w3-hover-opacity w3-padding-small")))))

(define (centered-image image)
  "Create a centered image from source IMAGE."
  `((div (@ (class "w3-container w3-center")
		   (style "text-align: center"))
		(img (@ (src ,image))))))


;;; Post processing utilities ----------------------------------------


(define (date year month day)
  "Create a SRFI-19 date for the given YEAR, MONTH, DAY"
  (let ((tzoffset (tm:gmtoff (localtime (time-second (current-time))))))
    (make-date 0 0 0 0 day month year tzoffset)))

(define (first-paragraph post)
  "Extract the first paragraph from POST."
  (let loop ((sxml (post-sxml post))
             (result '()))
    (match sxml
      (() (reverse result))
      ((or (('p ...) _ ...) (paragraph _ ...))
       (reverse (cons paragraph result)))
      ((head . tail)
       (loop tail (cons head result))))))

(define (contains? l m)
  "Check if LIST contains MEMBER."
  (if (null? l) #f
      (or (equal? (first l) m)
	  (contains? (drop l 1) m))))

(define (research? post)
  "Check if POST has a research tag."
  (contains? (post-ref post 'tags) "research"))

(define (misc? post)
  "Check if POST has a misc tag."
  (contains? (post-ref post 'tags) "misc"))

(define (research-posts posts)
  "Returns POSTS that contain research tag in reverse chronological order."
  (posts/reverse-chronological (filter research? posts)))

(define (misc-posts posts)
  "Returns POSTS that contain misc tag in reverse chronological order."
  (posts/reverse-chronological (filter misc? posts)))


;;; Website layout ---------------------------------------------------


(define default-theme
  (theme #:name "default-theme"
	 #:layout
	 (lambda (site title body)
	   `((doctype "html")

             ;; Head
	     (head
	      (meta (@ (charset "utf-8")))
	      (meta (@ (name "viewport") (content "width=device-width, initial-scale=1")))
	      (title ,(string-append title " — " (site-title site)))
              ,(external-stylesheet "https://www.w3schools.com/w3css/4/w3.css")
	      ,(external-stylesheet "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css")
	      ,(external-stylesheet "https://cdn.rawgit.com/jpswalsh/academicons/master/css/academicons.min.css")
	      ,(external-stylesheet "https://fonts.googleapis.com/css?family=Raleway")
	      (style "body, h1, h2 {font-family: 'Raleway', Arial, sans-serif;height: 100%;}")
	      (script "MathJax = { tex: {inlineMath: [['$', '$']]} };")
              (script (@ (id "MathJax-script")
			 (src "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"))))

	     ;; Body
             (body

	     (header (@ (style "background: #9e9e9e; margin-bottom:80px;"))
	     (div (@ (class "w3-container")
	             (style "text-align: justify; margin-left:auto; margin-right:auto; max-width:800px"))
		  ;; Header with navigation buttons
		  (div (@ (class "w3-panel w3-opacity"))
		      (div (@ (class "w3-bar w3-light-grey"))
		      ,(nav-button "Home" "/index.html")
		      ,(nav-button "About" "/about.html")
		      ,(nav-button "Research" "/research.html")
		      ,(nav-button "Miscellany" "/misc.html")))))

	     (div (@ (class "w3-container")
	             (style "text-align: justify; margin-left:auto; margin-right:auto; max-width:800px"))
		  ;; Main body of page
		  ,body)
                       
             ;; Footer
	     (footer (@ (style "background: #9e9e9e; height: 100%; min-height:100%; margin-top:80px;")) 
	     (div (@ (class "w3-container w3-center w3-xxlarge")
		     (style "margin-left:auto; margin-right:auto; max-width:800px;"))
		  (p ,%github-button
		     ,%bitbucket-button
		     ,%linkedin-button
		     ,%orcid-button
		     ,%arxiv-button
		     ,%ads-button)
                  (p (@ (class "w3-small"))
		     "© 2019 Lewis Weinberger "
                     ,%cc-by-sa-button
		     (br)
                     "This website is built with "
                     ,(link "Haunt" "http://haunt.dthompson.us")
                     ", a static site generator written in "
		     ,(link "Guile Scheme" "https://gnu.org/software/guile")
		     "."
		     (br)
                     "Powered by the "
                     ,(link "w3.css" "https://www.w3schools.com/w3css/default.asp") 
                     " framework."))))))
         #:post-template
         (lambda (post)
           `((h1 (@ (class "title"))
		 ,(post-ref post 'title))
             (div (@ (class "date"))
                  ,(date->string (post-date post)
                                 "~B ~d, ~Y"))
             (div (@ (class "post"))
                  ,(post-sxml post))))
         #:collection-template
         (lambda (site title posts prefix)
           (define (post-uri post)
             (string-append "/" (or prefix "")
                            (site-post-slug site post) ".html"))
 
           `((h1 ,title)
             ,(map (lambda (post)
                     (let ((uri (string-append "/"
                                               (site-post-slug site post)
                                               ".html")))
                       `(div (@ (class "summary"))
                             (h2 (a (@ (href ,uri)
				       (style "text-decoration: none;")
				       (class "w3-text-blue-gray"))
				    ,(post-ref post 'title)))
                             (div (@ (class "date"))
                                  ,(date->string (post-date post)
                                                 "~B ~d, ~Y"))
                             (div (@ (class "post"))
                                  ,(first-paragraph post))
                             ,(link "read more..." uri))))
                   posts)))))

(define (static-page title file-name body)
  "Create a static page with TITLE at html file FILENAME using page BODY."
  (lambda (site posts)
    (make-page file-name
	       (with-layout default-theme site title body)
	       sxml->html)))


;;; Custom markdown reader --------------------------------------------------


(define (sxml-identity . args) args)

;; Put code in a nice blue box
(define (code-block . tree)
  (sxml-match tree
              [(pre (code ,source))
               `(div (@ (class "w3-container w3-border w3-padding-16 w3-pale-blue"))
		     (pre (@ (style "overflow: auto"))
			  (code ,source)))]
	      [,other other]))

;; Convert hrefs to custom hoverable link
(define (hover-link . tree)
  (sxml-match tree
	      [(a (@ (href ,uri) . ,_) . ,name) `(,(link name uri))]))

;; Center all images
(define (center-images . tree)
  (sxml-match tree
	      [(img (@ (src ,uri) . ,_)) `(,(centered-image uri))]))

(define %commonmark-rules
  `((pre . ,code-block)
    (a . ,hover-link)
    (img . ,center-images)
    (*text* . ,(lambda (tag str) str))
    (*default* . ,sxml-identity)))

(define (post-process-commonmark sxml)
  (pre-post-order sxml %commonmark-rules))

(define commonmark-reader*
  (make-reader (make-file-extension-matcher "md")
               (lambda (file)
                 (call-with-input-file file
                   (lambda (port)
                     (values (read-metadata-headers port)
                             (post-process-commonmark
                              (commonmark->sxml port))))))))
