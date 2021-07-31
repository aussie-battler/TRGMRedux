require('dotenv').config();
const { startGroup, getInput, endGroup, setFailed } = require('@actions/core');
const fsx = require('fs-extra');
const path = require('path');
const axios = require('axios').default;

const QUERY_FILES_ENDPOINT = 'https://api.steampowered.com/IPublishedFileService/QueryFiles/v1/';

const ARMA_APP_ID = 107410;
const RANKED_BY_TEXT_SEARCH = 12;
const THEACE0296_CREATOR_ID = '76561198044344337';

const queryForTRGM = (cursor = '*') => {
  return axios.get(QUERY_FILES_ENDPOINT, {
    params: {
      key: process.env.STEAM_API_KEY,
      appid: ARMA_APP_ID,
      query_type: RANKED_BY_TEXT_SEARCH,
      cursor: cursor,
      search_text: '[Nightly] TRGM-Redux',
      return_tags: true,
      return_kv_tags: true,
      return_short_description: true,
      return_metadata: true,
    },
  });
};

(async () => {
  try {
    startGroup('Getting list of files to upload...');
    const releaseAssetsPath = getInput('path') || path.resolve(__dirname, '../../Mission-Templates/');
    const releaseAssets = fsx
      .readdirSync(path.normalize(releaseAssetsPath))
      .filter(file => file.includes('TRGM-Redux'));
    const releaseAssetsMap = {};
    for (const releaseAsset of releaseAssets) {
      releaseAssetsMap[`[Nightly] ${releaseAsset}.pbo`.toLowerCase().replace(/\x20/g, '%20')] = releaseAsset;
    }
    endGroup();

    startGroup('Getting list of existing workshop items...');
    let currentCursor = '*';
    let existingFiles = [];
    while (currentCursor) {
      currentCursor = null;
      try {
        const res = await queryForTRGM(currentCursor);
        if (
          res?.status === 200 &&
          res?.data &&
          res?.data?.response &&
          res?.data?.response?.publishedfiledetails &&
          res?.data?.response?.publishedfiledetails.length > 0
        ) {
          currentCursor = res.data.response.next_cursor;
          for (const publishedFileDetail of res.data.response.publishedfiledetails) {
            if (
              publishedFileDetail.creator === THEACE0296_CREATOR_ID &&
              Object.keys(releaseAssetsMap).includes(publishedFileDetail.filename.toLowerCase())
            ) {
              existingFiles = [ ...existingFiles, releaseAssetsMap[publishedFileDetail.filename.toLowerCase()] ];
              currentCursor = null;
              break;
            }
          }
        } else {
          console.error(res.statusText);
        }
      } catch (error) {
        console.error(error);
      }
    }

    console.debug(JSON.stringify(existingFiles, null, 2));

    endGroup();
  } catch (error) {
    console.error('An error occured while updating release assets:');
    console.error(error.name);
    console.error(error.message);
    console.error(error.stack);
    setFailed(error);
    process.exit(2);
  }
})();
