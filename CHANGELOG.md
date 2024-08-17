# v1.0.4
- Don't ask about v1.0.3
- Added emblem and color previews when mousing over the dropdown menu elements
  - I might expand this into also displaying the preview on the model but the ancient TabardModel APIs make it difficult. No promises.
- Adjusted some frame positioning
- Removed an erroneous `Tabardy.Debug = true;`

# v1.0.2

- Added support for 11.0.0
- Updated dropdowns to new dropdowns and menus
- Removed all bugs, there are zero bugs left

# v1.0.0

- World's first tabard designer remake! (no idea if this is true)

This initial release may be missing some features that could come down the line, though I'm not promising anything.

So far, these are the things missing from the addon that could be added later:
- Emblem previews on the emblem dropdown
- Emblem color preview on the emblem texture shown beside the character
- Better model controls + zoom

These are things that are missing and **cannot** be added due to limitations of the underlying API:
- Dropdowns for the border style and border color

Current known issues:
- If you manage to open the frame when you're not at a tabard vendor, your character might get stuck with the tabard texture on them.
  - To fix this, you can either relog or go visit a tabard vendor and toggle the UI.
