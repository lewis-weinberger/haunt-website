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

(use-modules (haunt builder blog)
             (haunt builder assets)
             (haunt post)
             (haunt reader commonmark)
             (haunt site)
	     (haunt config)
	     (useful))

;; Static "Home"
(define home-page
        (static-page
         "Home"
         "index.html"
	 `(,(centered-image "images/mainframe_256x256.gif"))))

;; Static "About" page
(define about-page
        (static-page
         "About"
         "about.html"
         `((h1 "About")
	   (p "This is the personal website of Lewis Weinberger. "
	      "I am currently an astrophysics PhD student at the University of "
	      "Cambridge's "
	      ,(link "Institute of Astronomy" "https://www.ast.cam.ac.uk/")
	      ". My research has focused on the "
	      "inter-galactic medium (IGM), which is the stuff "
	      (i "in-between")
	      " galaxies "
	      "(no, it's not just vacuum), in particular how this medium evolved"
	      "alongside galaxies in the early Universe."
	      " Outside of my PhD work, I'm a big fan of computers (all computers, "
	      "great and small)... A lot of my research makes use of High "
	      "Performance Computing (HPC), running calculations on "
              ,(link "supercomputers" "https://www.hpc.cam.ac.uk/")
	      ", but I also enjoy learning about programming languages "
	      "and paradigms outside of scientific computing.")
           (br)
	   ,(centered-image "images/profile.png")
	   (br)
	   (p "This site was written in the LISP dialect Scheme (GNU Guile, version "
              ,(version)
	      ") and built with the Haunt library (version "
	      ,%haunt-version
	      "). Under the hood it was heavily inspired by the websites "
	      ,(link "dthompson.us" "https://dthompson.us/")
	      " and "
	      ,(link "hpc.guix.info" "https://hpc.guix.info/")
	      ". The source code can be found on "
	      ,(link "GitHub" "https://github.com/lewis-weinberger/haunt-website")	 
	      ".")
	   (br)
	   ,(centered-image "images/github_profile.png")
           (br)
	   (h2 "Contact Info")
	   (p (i (@ (class "fa fa-envelope fa-fw")))
	      " lewis.weinberger"
	      (i (@ (class "fa fa-at")))
	      "ast.cam.ac.uk"))))

;; Collection of miscellaneous posts
(define %misc
  `(("Recent Posts" "misc.html" ,misc-posts)))

;; Collection of research-related posts
(define %research
  `(("Published Work" "research.html" ,research-posts)))

;; Build site
(site #:title "Lewis Weinberger's Homepage"
      #:domain "lewis-weinberger.github.io"
      #:default-metadata
      '((author . "Lewis Weinberger")
        (email  . "lhw28@cam.ac.uk"))
      #:readers (list commonmark-reader*)
      #:builders (list (blog #:theme default-theme #:collections %misc)
		       (blog #:theme default-theme #:collections %research)
		       home-page
		       about-page
                       (static-directory "images")))
