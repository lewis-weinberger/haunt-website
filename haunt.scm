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

(use-modules (haunt asset)
             (haunt builder blog)
             (haunt builder assets)
             (haunt html)
             (haunt page)
             (haunt post)
             (haunt reader)
             (haunt reader commonmark)
             (haunt site)
             (haunt utils)
	     (haunt config)
             (commonmark)
	     (useful)
	     (web uri))

;; Static "Home"
(define home-page
        (static-page
         "Home"
         "home.html"
         `((img (@ (class "")
		   (src "images/test.png"))))))

;; Static "About" page
(define about-page
        (static-page
         "About"
         "about.html"
         `((img (@ (class "")
		   (src "images/github_profile.png")))
	   (p "This is the personal website of Lewis Weinberger. "
	      "I am a computerphile and astrophysics PhD student. "
	      "MORE INFORMATION HERE!")
           (br)
	   (p "This site was written in Guile Scheme (version "
              ,(version)
	      ") and built with Haunt (version "
	      ,%haunt-version
	      "). Under the hood it was inspired by "
	      ,(link "dthompson.us" "https://dthompson.us/")
	      " and "
	      ,(link "hpc.guix.info" "https://hpc.guix.info/")
	      ". The source code can be found on "
	      ,(link "GitHub" "https://github.com/lewis-weinberger/haunt-website")	 
	      ".") 
           (br)
	   (h3 "Contact Info")
	   (p (i (@ (class "fa fa-envelope fa-fw")))
	      " lewis.weinberger"
	      (i (@ (class "fa fa-at")))
	      "ast.cam.ac.uk")
	   (br)
	   (img (@ (class "")
		   (src "images/profile.png"))))))

;;; Build site
(site #:title "Lewis Weinberger's Homepage"
      #:domain "lewis-weinberger.github.io"
      #:default-metadata
      '((author . "Lewis Weinberger")
        (email  . "lhw28@cam.ac.uk"))
      #:readers (list commonmark-reader)
      #:builders (list (blog #:theme default-theme)
                       home-page
		       about-page
		       (static-directory "css")
                       (static-directory "images")))
