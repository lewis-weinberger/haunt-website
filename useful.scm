;;;
(define-module (useful)
  #:use-module (haunt html)
  #:use-module (haunt utils)
  #:use-module (haunt asset)
  #:use-module (haunt builder blog)
  #:use-module (haunt builder assets)
  #:use-module (haunt page)
  #:use-module (haunt post)
  #:use-module (haunt reader)
  #:use-module (haunt reader commonmark)
  #:use-module (haunt site)
  #:use-module (haunt config)
  #:use-module (commonmark)
  #:use-module (useful)
  #:use-module (web uri)
  #:export (link
	    nav-button
	    stylesheet
	    external-stylesheet
	    %cc-by-sa-button
	    %github-button
	    %bitbucket-button
	    %linkedin-button
	    %orcid-button
	    %arxiv-button
	    %ads-button
	    default-theme
	    static-page))

;; Links
(define (link name uri)
  `(a (@ (href ,uri)
	 (class "w3-hover-opacity"))
      ,name))

;; Navigation button
(define (nav-button name uri)
  `(a (@ (class "w3-bar-item w3-button w3-light-grey w3-mobile")
	 (href ,uri))
      ,name))

;; Local stylesheets
(define (stylesheet name)
  `(link (@ (rel "stylesheet")
            (href ,(string-append "/css/" name ".css")))))

;; External stylesheets
(define (external-stylesheet name)
  `(link (@ (rel "stylesheet")
            (href ,name))))

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

;; Default layout for the website
(define default-theme
  (theme #:name "Lewis Weinberger"
	 #:layout
	 (lambda (site title body)
	   `((doctype "html")

             ;; Head
	     (head
	      (meta (@ (charset "utf-8")))
	      (meta (@ (name "viewport") (content "width=device-width, initial-scale=1")))
	      (title ,(string-append title " — " (site-title site)))
	      ,(external-stylesheet "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css")
	      ,(external-stylesheet "https://cdn.rawgit.com/jpswalsh/academicons/master/css/academicons.min.css")
	      ,(external-stylesheet "https://fonts.googleapis.com/css?family=Raleway")
              ,(stylesheet "w3"))

	     ;; Body
             (body (@ (style "font-family: 'Raleway', Arial, sans-serif"))
             ;; Header with navigation buttons
	     (div (@ (class "w3-panel w3-center w3-opacity")
	             (style "padding:50px 16px"))
		  (div (@ (class "w3-bar w3-border"))
		  ,(nav-button "Home" "/home.html")
		  ,(nav-button "About" "/about.html")
                  ,(nav-button "Miscellany" "/index.html")))

	     ;; Main body of page
	     (div (@ (class "w3-card w3-padding")
	             (style "text-align: center; margin-top:20px; margin-bottom:80px; margin-left:auto; margin-right:auto; max-width:800px"))
        	  ,body)
                       
             ;; Footer
	     (div (@ (class "w3-container w3-padding-64 w3-light-grey w3-center w3-xxlarge"))
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
                     " framework.")))))))

(define (static-page title file-name body)
        (lambda (site posts)
        (make-page file-name
                   (with-layout default-theme site title body)
                   sxml->html)))
