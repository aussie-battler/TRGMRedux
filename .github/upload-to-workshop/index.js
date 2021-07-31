require('dotenv').config();
const { startGroup, getInput, endGroup, setFailed } = require('@actions/core');
const fsx = require('fs-extra');
const path = require('path');
const axios = require('axios').default;

const QUERY_FILES_ENDPOINT = 'https://api.steampowered.com/IPublishedFileService/QueryFiles/v1/';

const ARMA_APP_ID = 107410;
const RANKED_BY_TEXT_SEARCH = 12;
const THEACE0296_CREATOR_ID = '76561198044344337';

const ARMA_FILE_TO_NAME_MAP = {
  altis: 'Altis',
  cam_lao_nam: 'Cam Lao Nam',
  chernarus: 'chernarus',
  chernarus_summer: 'chernarus_summer',
  chernarus_winter: 'chernarus_winter',
  cup_chernarus_a3: 'cup_chernarus_a3',
  desert_island: 'desert_island',
  enoch: 'enoch',
  fallujah: 'fallujah',
  intro: 'intro',
  kunduz: 'kunduz',
  lythium: 'Livonia',
  malden: 'Malden',
  porto: 'porto',
  prei_khmaoch_luong: 'prei_khmaoch_luong',
  rhspkl: 'rhspkl',
  ruha: 'ruha',
  sara: 'sara',
  stratis: 'Stratis',
  takistan: 'takistan',
  tanoa: 'Tanoa',
  tem_kujari: 'tem_kujari',
  utes: 'utes',
  vt7: 'vt7',
  wake: 'wake',
  woodland_acr: 'woodland_acr',
  zargabad: 'zargabad',
  abel: 'abel',
  abramia: 'abramia',
  archipelago: 'archipelago',
  australia: 'australia',
  bootcamp_acr: 'bootcamp_acr',
  cain: 'cain',
  chernarus_isles: 'chernarus_isles',
  desert_e: 'desert_e',
  dingor: 'dingor',
  eden: 'eden',
  gm_weferlingen_summer: 'Weferlingen',
  gm_weferlingen_winter: 'Weferlingen W.',
  isladuala3: 'isladuala3',
  lingor3: 'lingor3',
  mountains_acr: 'mountains_acr',
  noe: 'noe',
  pabst_yellowstone: 'pabst_yellowstone',
  panthera3: 'panthera3',
  pja310: 'pja310',
  provinggrounds_pmc: 'provinggrounds_pmc',
  saralite: 'saralite',
  sara_dbe1: 'sara_dbe1',
  shapur_baf: 'shapur_baf',
  tembelan: 'tembelan',
  winthera3: 'winthera3',
  xcam_taunus: 'xcam_taunus',
};

const queryForTRGM = (cursor = '*', search_text = '[Nightly] TRGM-Redux') => {
  return axios.get(QUERY_FILES_ENDPOINT, {
    params: {
      key: process.env.STEAM_API_KEY,
      appid: ARMA_APP_ID,
      query_type: RANKED_BY_TEXT_SEARCH,
      cursor: cursor,
      search_text: search_text,
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
      const mapName = /\.(.+)/.exec(releaseAsset)[1].toLowerCase();
      if (ARMA_FILE_TO_NAME_MAP[mapName] && ARMA_FILE_TO_NAME_MAP[mapName] !== ARMA_FILE_TO_NAME_MAP[mapName].toLowerCase()) {
        releaseAssetsMap[
          `[Nightly] ${releaseAsset.substr(0, releaseAsset.lastIndexOf('.'))} (${ARMA_FILE_TO_NAME_MAP[mapName]})`
        ] = releaseAsset;
      }
    }
    endGroup();

    startGroup('Getting list of existing workshop items...');
    let existingFiles = [];
    for (const [name, asset] of Object.entries(releaseAssetsMap)) {
      let currentCursor = '*';
      while (currentCursor) {
        currentCursor = null;
        try {
          const res = await queryForTRGM(currentCursor, name);
          if (
            res?.status === 200 &&
            res?.data &&
            res?.data?.response &&
            res?.data?.response?.publishedfiledetails &&
            res?.data?.response?.publishedfiledetails.length > 0
          ) {
            for (const publishedFileDetail of res.data.response.publishedfiledetails) {
              if (
                publishedFileDetail.creator === THEACE0296_CREATOR_ID &&
                name.toLowerCase() === publishedFileDetail.title.toLowerCase()
              ) {
                existingFiles = [...existingFiles, asset];
              }
            }
            currentCursor = res.data.response.next_cursor;
          } else {
            console.error(res.statusText);
          }
        } catch (error) {
          console.error(error);
        }
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
