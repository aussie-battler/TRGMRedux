require('dotenv').config();
const { startGroup, getInput, endGroup, setFailed } = require('@actions/core');
const fsx = require('fs-extra');
const path = require('path');
const axios = require('axios').default;

const steamworks = require('./steamworks-node');
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
    const changelog = getInput('changelog') || 'Changes...';
    startGroup('Getting list of files to upload...');
    const releaseAssetsPath = getInput('path') || path.resolve(__dirname, '../../Mission-Templates/');
    const releaseAssets = fsx
      .readdirSync(path.normalize(releaseAssetsPath))
      .filter(file => file.includes('TRGM-Redux'));
    const releaseAssetsMap = {};
    for (const releaseAsset of releaseAssets) {
      const mapName = /\.(.+)/.exec(releaseAsset)[1].toLowerCase();
      if (
        ARMA_FILE_TO_NAME_MAP[mapName] &&
        ARMA_FILE_TO_NAME_MAP[mapName] !== ARMA_FILE_TO_NAME_MAP[mapName].toLowerCase()
      ) {
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
                existingFiles = [
                  ...existingFiles,
                  {
                    name,
                    asset,
                    appId: ARMA_APP_ID,
                    itemId: publishedFileDetail.publishedfileid,
                    contentPath: path.normalize(path.resolve(releaseAssetsPath, asset)),
                    changelog,
                    ...publishedFileDetail,
                  },
                ];
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
    endGroup();

    console.log(JSON.stringify(existingFiles, null, 2));

    // startGroup('Initializing greenworks...');
    // if (greenworks.init()) {
    //   greenworks.ugcGetUserItems(
    //     {
    //       app_id: ARMA_APP_ID,
    //       page_num: 1,
    //     },
    //     greenworks.UGCMatchingType.Items,
    //     greenworks.UserUGCListSortOrder.TitleAsc,
    //     greenworks.UserUGCList.Published,
    //     items => {
    //       const files = fsx
    //         .readdirSync(path.resolve('A:/TRGMRedux Nightly'))
    //         .filter(
    //           file =>
    //             ARMA_FILE_TO_NAME_MAP[/\.(.+?)\.pbo/.exec(file)[1].toLowerCase()] !==
    //             /\.(.+?)\.pbo/.exec(file)[1].toLowerCase()
    //         )
    //         .map(file => ({
    //           title: `[Nightly] ${path.basename(file).substr(0, path.basename(file).indexOf('.'))} (${
    //             ARMA_FILE_TO_NAME_MAP[/\.(.+?)\.pbo/.exec(file)[1].toLowerCase()]
    //           })`,
    //           file: path.resolve('A:/TRGMRedux Nightly', file).replace(/\\|\//g, '/'),
    //         }));
    //       const updateFiles = [];
    //       const updatePromises = existingFiles.map(exisitingFile => {
    //         const { name, asset, appId, itemId, contentPath, changelog } = exisitingFile;
    //         const matchingItem = items.find(item => item.publishedFileId === itemId || item.title === name);
    //         const matchingFile = files.find(file => file.title.toLowerCase() === matchingItem.title.toLowerCase());
    //         const tags = Array.from(new Set([
    //           ...'Singleplayer,Infantry,Coop,Vehicles,Scenario,Dependency,Air,Water,Multiplayer,Tag Review'.split(',').filter(tag => !!tag),
    //           ...matchingItem.tags.split(',').filter(tag => !!tag),
    //         ]));
    //         if (matchingFile && matchingItem) {
    //           startGroup(`Matching file found for: ${matchingItem.title} -> ${matchingFile.file} | ItemId: ${matchingItem.publishedFileId}, updating!`);
    //           endGroup();
    //           updateFiles.push({
    //             itemId: matchingItem.publishedFileId,
    //             file  : matchingFile.file,
    //           });
    //           // return new Promise(res => {
    //           //   greenworks.updatePublishedWorkshopFile(
    //           //     { tags: tags },
    //           //     matchingItem.publishedFileId,
    //           //     '',
    //           //     '',
    //           //     '',
    //           //     '',
    //           //     () => {
    //           //       startGroup(`${matchingItem.title} updated!`);
    //           //       endGroup();
    //           //       res(true);
    //           //     },
    //           //     err => {
    //           //       startGroup(`Failed to update ${matchingItem.title}!`);
    //           //       console.error(err);
    //           //       endGroup();
    //           //       res(false);
    //           //     }
    //           //   );
    //           // });
    //           // return new Promise(res => {
    //           //   greenworks.saveFilesToCloud(
    //           //     [matchingFile.file],
    //           //     () => {
    //           //       greenworks.fileShare(
    //           //         matchingFile.file,
    //           //         file_handle => {
    //           //           greenworks.updatePublishedWorkshopFile(
    //           //             { tags: tags },
    //           //             matchingItem.publishedFileId,
    //           //             file_handle,
    //           //             '',
    //           //             '',
    //           //             '',
    //           //             () => {
    //           //               startGroup(`${matchingItem.title} updated!`);
    //           //               endGroup();
    //           //               res(true);
    //           //             },
    //           //             err => {
    //           //               startGroup(`Failed to update ${matchingItem.title}!`);
    //           //               console.error(err);
    //           //               endGroup();
    //           //               res(false);
    //           //             }
    //           //           );
    //           //         },
    //           //         err => {
    //           //           startGroup(`Failed to share ${matchingFile.file}!`);
    //           //           console.error(err);
    //           //           endGroup();
    //           //           res(false);
    //           //         }
    //           //       );
    //           //     },
    //           //     err => {
    //           //       startGroup(`Failed to upload ${matchingFile.file}!`);
    //           //       console.error(err);
    //           //       endGroup();
    //           //       res(false);
    //           //     }
    //           //   );
    //           // });
    //         } else {
    //           startGroup(`No matching file found for: ${matchingItem.title}!`);
    //           endGroup();
    //           return new Promise(res => setTimeout(res), 100);
    //         }
    //       });
    //       Promise.all(updatePromises)
    //         .then(() => {
    //           console.log(JSON.stringify(updateFiles, null, 2));
    //           process.exit(0);
    //         })
    //         .catch(() => process.exit(1));
    //       1;
    //     },
    //     () => process.exit(1)
    //   );
    // } else {
    //   setFailed('Greenworks failed to initialize!');
    // }
    // endGroup();
  } catch (error) {
    console.error('An error occured while updating release assets:');
    console.error(error.name);
    console.error(error.message);
    console.error(error.stack);
    setFailed(error);
    process.exit(2);
  }
})();
