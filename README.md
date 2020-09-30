![Image of Design](/images/design.png)


# Procreate Tech Challenge

The initial task was to create a new ui and implement the codes to adjust the hue saturation and brightness of a picture. 
To sum down things that I have done
  - Created a new UI
  - Implemented Metal for the first time
  - Animations, codes and all.

# Important notes

  - I didn't have an actual iPad to test it so it was only tested through simulator on an iPad 12.9 inch running iOS 13.2. You might have different results running on iOS 14 as I did not upgrade to Big Sur yet.
  - I've used a slider from another Github to speed up the process as it was perfect for the sliders. I did change the codes slightly to meet one of the requirements (https://github.com/jonhull/GradientSlider)
  - I've implemented Metal for the first time and noticed something weird about it, the fact that my image is always flipped upside down. I've done a bit of research and seen another person saying that it actually only happens on the simulator and not in an actual iPad. 
  >https://stackoverflow.com/questions/60164536/flipped-picture-after-render-in-metal
  - As I don't have an iPad to test, I could not verify it. If it does come up with flipped image on an actual iPad, please take it like it was a mistake of my part. 
  - I could not fullfill the second condition of the test.(The slider don't snap to the touch point but instead translate as you move your finger.) That is totally my fault as I should have probably spent a bit more time on it rather than other parts of the code.I had a bit of work on it done, as you'll see from the commented area but I did not feel like it was up to par.

# Things I could have improved
What an amazing learning opportunity, and I would like to thank you guys for coming up with this test. Below is a list of things I would improve if I had the chance
  - Add a done button to save the state of the image so that you can apply multiple times saturation (was not sure if this was required)
  - Drag and moving the panel anywhere on the screen
  - Finished the second part where it does not stick to your finger and translates
  - Used a different way of applying effects other than CIFilters
  - Wrote UI Tests
  - Worked better with Metal