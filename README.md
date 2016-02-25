[![Build Status](https://travis-ci.org/WGBH/openvault3.svg?branch=master)](https://travis-ci.org/WGBH/openvault3)

# openvault3

A new version of [Openvault](http://openvault.wgbh.org),
to replace the [current one](https://github.com/wgbh/openvault).
Planning documents are available on [the intranet](https://atlas.wgbh.org/confluence/display/OV).

## Deploy Servers

There are four steps to get the site up from scratch:
- Request servers and everything else from AWS.
- Use Ansible for a basic configuration of the servers.
- Deploy the site with Capistrano.
- Ingest the PBCore.

On an on-going basis there will be:
- Capistrano redeploys to the demo server
- and swaps of the production and demo servers.

For more details, see `scripts/deploy.sh`: Ideally, this will run as-is,
but you could also read it as instructions, and do each step manually.

## Ingest PBCore

The authoritative metadata records for the site come from a FileMaker database which exports a zip
of PBCore xml files, with one description document per file. No further cleaning of the PBCore
is done as part of ingest, in contrast to the AAPB.

For development the fixtures may be enough:

```
$ ruby scripts/ingest.rb --stdout-log --same-mount --dirs spec/fixtures/pbcore
```

The ingester can read the zip export directly: Unzipping is unnecessary.

```
$ ruby scripts/ingest.rb --stdout-log --same-mount --files ~/Downloads/export.zip
```

If you want to reingest just a few files from a zip, they should be selectively unzipped first:

```
$ mkdir ~/unzips
$ unzip  ~/Downloads/export.zip V_1234.xml V_5678.xml -d ~/unzips
$ ruby scripts/ingest.rb --stdout-log --same-mount --dirs ~/unzips
```

## Asset Proxy, Thumbnail and Transcript Files

Asset records that contain media we're making available on Open Vault should have an asset proxy file.  This will be a lower quality .jpg derivative for an image asset, a .mp3 derivative for an audio asset, or a .mp4 and .webm derivative for a video asset.

Video asset derivatives will have an "Open Vault" transparent watermark superimposed on the video image.  Video assets will also have a thumbnail (.jpg) screen grab of some interesting part of the video.  Image assets will also have a thumbnail file derivative created.  Some audio assets will have custom thumbnail images, but for the most part audio assets will use the website's default audio asset record image.  

If an audio or video asset has a transcript .xml file we're making available, it will also be uploaded to Amazon S3.

**Naming These Files**

Every asset record in the Open Vault PBCore database has a ```OPEN_VAULT_UID``` value assigned, for example ```V_4D37F2D8E1054BA49999027BF9D18957```

Any asset proxy, asset thumbnail, or asset transcript created relating to that asset record should use the ```OPEN_VAULT_UID``` value as it's file name.

**asset=** V_4D37F2D8E1054BA49999027BF9D18957

**asset_proxy=** V_4D37F2D8E1054BA49999027BF9D18957.mp4, V_4D37F2D8E1054BA49999027BF9D18957.webm

**asset_thumbanil=** V_4D37F2D8E1054BA49999027BF9D18957.jpg

**asset_transcript=** V_4D37F2D8E1054BA49999027BF9D18957.xml

### Uploading to Amazon S3

You can use the AWS web interface to upload asset proxies, thumbnails, or transcripts for Open Vault but for uploading multiple files you should use the Amazon CLI tool.  The transfer speed is a lot faster and large transfers shouldn't time out.

[Follow the documentation](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) to set up CLI with your Access Key, Secret Access Key, and Default region name.

The buckets are located under **/catalog/**

- /asset_proxies/ is for image, audio, or video asset proxy files (.jpg, .mp3, .mp4 and .webm)
- /asset_thumbnails/ is for asset thumbnails (.jpg)
- /asset_transcripts/ is for asset transcript files (.xml)

Copy Directory of Files to S3:
```
aws s3 cp /local/folder/of/stuff s3://openvault.wgbh.org/bucket-name --recursive
```

Double Check Files Were Uploaded:
```
aws s3 ls s3://openvault.wgbh.org/bucket-name --recursive >> /Users/logs/s3_proxies.csv
```
