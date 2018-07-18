***Problem Statement: 
Large file containing 1.4 billion clear text credentials (breachcompilation.zip) were leaked in the public.
Cleaning up the datasets by removing personal details and do analysis on password trends to answer various questions.
-Password complexity usage including length, special chars, alpha numeric, char frequency across various domains.
-Degree of randomness in password.
-Various trends on selecting passwords such as dictionary chars, movie names, superheroes
-Based on trend calculate avg time to crack if specific method is used for brute-forcing such as dictionary wordlists.

***Data Acquisition:
Dataset was acquired by below pastebin links which points to Magent links to download torrent link whose total size is around 41 GB.
Dataset download: 
-https://pastebin.com/R8Aj8Ncq
-https://medium.com/4iqdelvedeep/1-4-billion-clear-text-credentials-discovered-in-a-single-database-3131d0a1ae14  
-https://www.reddit.com/r/pwned/comments/7hhqfo/combination_of_many_breaches/ 

Link to dataset with only passwords without Email IDs: https://gist.github.com/scottlinux/9a3b11257ac575e4f71de811322ce6b3

***Statistical Analysis:
-No of duplicate Records
-No of unique Passwords
-No of domains involved - corporate vs public domains. Domains per Countries.
-Same userid with different domains but same passwords.

***Visualizations:
-Distribution of datasets.
-Histogram on length of passwords.
-AlphaNumericSpecialChar Frequency.

***Pattern Analysis:
-Username substring as passwords.
-Common words which are substring of passwords.
-Password Walking - passwords containing letters, numbers, symbols close to each other on keyboard
-Patterns about brands, music, movies, superheroes, love, hate. sports, stars etc.
	
	• Likelihood of Passwords being in the Dataset ?
	• Password Sentiment Analysis
	• Degree of randomness (?)
	• Password similarity -lexical analysis
	• Password Complexity classification and publishing final results of the dataset.
