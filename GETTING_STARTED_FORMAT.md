# How to write a focused getting started guide

the folder structure should look like

```txt
folder_name
    images
        index_img1.jpg
        index_img2.jgp
        step1_img1.webp
        step1_movie1.mp4
        ...
    index.md
    step1.md
    step2.md
    ...
    summary.md
```

## Media Formats

All statistics images need to be in either JPEG or WEBP format. PNG can be used if there is a limited color palette for the
image and this will create a signfigicantly smaller size on disk.

All animations must be in WEBP or MP4 format
<https://cloudinary.com/guides/image-formats/gif-vs-webp>

## index.md

The index section begins with a paragraph that describes what they are going to learn. It should only be a couple of sentences describing the highlights

There should be the follow H2 sections

```markdown
## Who this is for
        What is their level of FiftyOne familiarity
        What is the level of expertise in the subject area
        What you assume they are trying to accomplish

## Assumed Knowledge
        CV concepts
        Image or dataset formats
        Python skills
        FiftyOne Concepts - give links to these so they can go learn more if they don't have the knowledge

## Time to complete
        This is only a very rough estimate

## Required packages
        Remind them to use a virtual env that already has fiftyone installed
        Give install instructions for whatever you need them to install. They should not hit any "package not installed" errors past this page

## Content
    a one sentence description for each sub-document that is linked

```

## Summary.md

This is the wrap up page. There should be one or more paragraphs explaining what they have learned

There should be the follow H2 sections after these paragraphs

```markdown

## Next Steps
        This could include:
            other focused getting starteds
            other datasets
            other models
            external readings
            join discord and any particular channels
            follow us on linkedin


```
