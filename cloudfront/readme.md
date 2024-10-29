updated bucket policy Create a CloudFront Origin Access Identity,
s3_origin_config => origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path

Update the S3 Bucket Policy to Allow Access from OAI:
Security: CDNs offer protection against DDoS attacks, provide secure data transmission through SSL/TLS,
and can include additional security features like web application firewalls (WAF) to safeguard content and user data

Improved Website Performance: CDNs reduce latency by caching content at edge locations close to users,
resulting in faster load times and a smoother browsing experience.

CloudFront to Deliver your Content?

Step 1: When the user sends a request for an object like an image file, 
DNS routes the request to the closest CloudFront edge location to serve the user request.

Step 2: At the edge location, the requested files are checked in its cache. 
If the requested files are found then it is returned to the user otherwise below steps are followed


    CloudFront now forwards the request to the origin server for the particular file.
    The origin servers send the requested files to the CloudFront edge location.
    When the first byte of file arrives from the origin server, 
    CloudFront starts forwarding it to the user and adds the files to the cache 
    in the edge location for the next time when someone again requests for the same file.

Step 3: The object remains in the cache of edge location for the provided duration present in file headers.

    CloudFront forwards the request for the object to the origin server to check if the file 
    at the edge location is updated or not.
    If the version of the file at the edge location is updated, then CloudFront 
    delivers the requested file to the user.
    If the version of the file at the edge location is not updated, 
    then the origin server sends the latest version of the file to CloudFront edge location. 
    Now CloudFront delivers the latest version of the object to the user and also stores it in the cache at the edge location
