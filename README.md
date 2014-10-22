UIWebViewResizeBug
==================

The example app demonstrating iOS8 bug when the frame is changed by user interaction on real device. iOS7 works.

The content is cliped after some resizing of the webview.

The red color is for WebView and yellow is for HTML content. 

At startup is the view in correct dimensions.
![Alt text](/before.PNG?raw=true "Before resize")
After resize the html is staring to be clipped.
![Alt text](/after.PNG?raw=true "After resize")
If you turn on the Safari inspector you can see that the HTML content has correct size.
![Alt text](/inspect.PNG?raw=true "After resize in inspector")