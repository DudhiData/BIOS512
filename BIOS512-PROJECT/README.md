The phishing URL dataset was pulled from the Machine Learning Repository website that was given as part of the set of recommended sites.   
It had around 54 features with 1 being the class and around 260,000 observations.  
The idea is using a logistic regression with regularization to reduce the number of features needed to allow my hardware to compute this without crashing.  
Additionally, the label we are predicting is a binary label, so predicting using a logistic regression is fitting.  
Dataset: https://archive.ics.uci.edu/dataset/967/phiusiil+phishing+url+dataset  
  - The dataset has a few pre-derived features (e.g. URLSimilarityIndex) and many binary features (e.g. HasObfuscation) from an academic paper mentioned at the website and some     others were derived separately
  - Since the binary features tend to mess with PCA and it was getting messy when I tried scaling everything I went with FAMD which would handle the binary features and also        deal with the scaling by itself
  - There were 2 main questions to address:
      1. How many of these features did I really need?
        a. Used around 20/54 just for clarity's sake and the 2 dimensions I used to separate them explained around 28% of variance.
      3. How easily can we separate a phishing URL from a legitimate one based on the features provided?
         a. Pretty clearly based on the pre-derived features and other binary ones but it would be difficult to do so without such extra features added on.

Setup: Use the Dockerfile and start.sh files to build and run the docker container with all the work. Just run the Rmd file and the visualizations should pop up. 
