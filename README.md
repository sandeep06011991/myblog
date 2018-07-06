--------------------TUTORIAL---------------------------

1. What is Jekyll and What does it exactly provide ??

	A tool in ruby for creating static websites. 
Advantages:
	1. seperation of content and layout(i.e styling) 
		ex. create a css/html style seperate from the actual content. 
		At runtime these 2 are combined together. Thus a single html css style can 
		be reused at multiple places.
	2. Create variables and use them through out the site. Like contact me or location etc.. 
	3. Parts of the website are made reusable by modularizing. Header and footer are typically the same. 
	So they are built differently and can be integrated at run time. 
	4. U can add extra, libraries for rendering. I added one for marked down, but thats one example.

2. Setting up and How to Run ??

	Install: sudo apt-get install jekyll
	
	running command: ~$ jekyll serve

3. Do I actually need to clone me and scrub me ?

    I remember trying the vanilla version of starting a new jekyll folder, but was a gigantic pain in the ass trying to customize it
    with basic layout. Also who wants to waste time doing styling.

4. So What happens when you run it ??

	Jekyll triggers the ruby compiler and creates plain html pages by substituting the the moldular layouts,
	rendering md text and putting in variables to plain html pages. 
	github actually does all of this and gives you a domain name.

	It is a service called github pages, which provides a server location which is {USERNAME}.github.io

	There are 2 approaches to how to host this site on the UMASS given IP. 
		
		1. Copy the generated __(_site) folder and paste internals at the provided location. (ex umass.edu/sandeep/..)
		2. Write a static html which redirects to github site. sandeep06011991.github.io. 
		I prefer this approach as (1 u any way need this repo to track changes, and any updates made are automatically redirected here)

5. How is the directory structure organized ??

    config.yml -> Contains important configuration and variables which can be substituted
    
    _includes & _layouts -> contains styling templates
    
    _papers,_posts -> contain sub entries (such as different paper reviews) for each page
    
    assets ->  static assets jpegs

    I have one layout called default.html, which borrows from templates in _includes
    When I have to create a page, just specify layout and required variables
    ex. index.html

    I have a 2 level architecture. Where category pages reside in root directory
    and children of each directory have folders

6. Create a new Category and add children .

    To create a new category change config.yml and add a new parent page in root directory
    update the collections entry, to gather children.
    To add a post in a category, create a child directory and add posts there
    Very important to follow the date, title and layout structure for each child post.
    Absence of these variables would lead to silent errors. 

