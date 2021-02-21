# SkuadAssignment

1. SearchViewController
    - This screen allows the user to enter the image search keyword.
    - This screen shows the last 10 successful search keywords in the table form below the textField. This mechanism has been implemented using LRUCache algorithm(LRUCache.swift).
    - User can tap on any sugestion in the table view and he will be seeing those images as a result on next view controller.
    - Suggestion list does not contain unsuccessful result (As per requirement). 
    
2. ImageSearchResultViewController
    - This page shows a list of preview images in a grid view with three items in a row.
    - This page also supports pagination when the user scrolls to the bottom of the list
    - Error handling is implemented in the form of an Alert view.
    - On this page, we make asynchronous call to the API to download the images (NetworkManager.swift) and we support image caching mechanism as well(ImageCacheManager.swift). 
    - While the page waits for the api response, the user sees an activity indicator.
    
3. FullScreenImageViewController
    - When user taps on any preview image on previous screen (ImageSearchResultViewController), user is brought here.
    - If preview image has not been downloaded then we show placeholder image while the actual image is fetched in background.
    - If preview image was available then we show preview image while the actual image is fetched in background and once the actual image is available then we replace the preview image with actual image as mentioned in webFormatURL.
    - Swiping left/right will show the previous/next images in the list in full screen mode with above rule applicable. 

