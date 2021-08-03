export = greenworks;
declare var greenworks: Greenworks;
type ErrorCallback = (err: any) => void;
interface Greenworks {
  /**
   * Returns a True when Steam APIs were successfully initialized, otherwise throw an error.
   */
  init: () => boolean;
  /**
   * Returns a boolean whether Steam APIs were successfully initialized or not.
   *
   * Note: When testing this, you need to launch and log in the Steam Client,
   * and create a steam_appid.txt file with your Steam APP ID
   * (or the steamworks example APP ID) under your app directory.
   */
  initAPI: () => boolean;
  /**
   * Returns a boolean whether Steam is running.
   */
  isSteamRunning: () => boolean;
  /**
   * If your app was not launched via Steam, this will signal Steam to launch your app, and then cause your app to quit.
   *
   * There's not a moment to lose after you call restartAppIfNecessary(), but if it returns true, your app is being restarted.
   */
  restartAppIfNecessary: (appId: number) => boolean;
  /**
   * Returns an number represents the app id of the current process.
   */
  getAppId: () => number;
  /**
   * Returns an Integer representing the app's build id. May change at any time based on backend updates to the game.
   */
  getAppBuildId: () => number;
  /**
   * Returns an SteamID object represents the current Steam user.
   */
  getSteamId: () => SteamID;
  /**
   * Returns a String represents the current language from Steam specifically set for the game.
   */
  getCurrentGameLanguage: () => string;
  /**
   * Returns a String represents the current language from Steam set in UI.
   */
  getCurrentUILanguage: () => string;
  /**
   * Not implement yet.
   */
  getCurrentGameInstallDir: () => void;
  /**
   * Returns a String representing the absolute path to the app's installation directory.
   */
  getAppInstallDir: (app_id: number) => string;
  getNumberOfPlayers: (success_callback: (num_of_players: number) => void, error_callback: ErrorCallback) => void;
  /**
   * Activate the game overlay with the option dialog opens.
   */
  activateGameOverlay: (option: 'Friends' | 'Community' | 'Players' | 'Settings' | 'OfficialGameGroup' | 'Stats' | 'Achievements') => void;
  /**
   * Return Boolean indicates whether Steam overlay is enabled/disabled.
   */
  isGameOverlayEnabled: () => boolean;
  /**
   * Return Boolean indicates whether Steam is in Big Picture mode. Will always return false if the application is not in Steam's game category.
   */
  isSteamInBigPictureMode: () => boolean;
  /**
   * Open a specified url in steam game overlay.
   */
  activateGameOverlayToWebPage: (url: string) => void;
  /**
   * Returns a Boolean indicates whether the user has purchased that app.
   */
  isSubscribedApp: (appId: number) => boolean;
  /**
   * Returns a Boolean indicating whether the app is currently installed. The app may not actually be owned by the user.
   *
   * Only works for base applications, for DLC use isDLCInstalled instead.
   */
  isAppInstalled: (appId: number) => boolean;
  /**
   * Returns an object that contains image’s width and height values.
   */
  getImageSize: (handle: number) => unknown;
  /**
   * Returns a Buffer that contains image data in RGBA format.
   */
  getImageRGBA: (handle: number) => Buffer;
  /**
   * Returns the 2 digit ISO 3166-1-alpha-2 format country code which client is running in, e.g "US" or "UK".
   */
  getIPCountry: () => string;
  /**
   * Gets the command line if the game was launched via Steam URL, e.g. steam://run/<appid>//<command line>/.
   *
   * This method is preferable to launching with a command line via the operating system, which can be a security risk.
   *
   * In order for rich presence joins to go through this and not be placed on the OS command line,
   * you must enable "Use launch command line" from the Installation > General page on your app.
   */
  getLaunchCommandLine: () => unknown;
  fileShare: (
    file_path: string,
    success_callback: (file_handle: string) => void,
    error_callback?: ErrorCallback
  ) => void;
  ugcGetItems: (
    options: { app_id: number; page_num: number },
    ugc_matching_type: UGCMatchingType,
    ugc_query_type: UGCQueryType,
    success_callback: (items: SteamUGCDetails) => void,
    error_callback?: ErrorCallback
  ) => void;
  ugcGetUserItems: (
    options: { app_id: number; page_num: number },
    ugc_matching_type: UGCMatchingType,
    ugc_list_sort_order: UserUGCListSortOrder,
    ugc_list: UserUGCList,
    success_callback: (items: SteamUGCDetails) => void,
    error_callback?: ErrorCallback
  ) => void;
  ugcDownloadItem: (
    download_file_handle: string,
    download_dir: string,
    success_callback: () => void,
    error_callback?: ErrorCallback
  ) => void;
  /**
   * Downloads/Synchronizes user's workitems (UserUGCList.Subscribed, UserMatchingType.Items) to the local sync_dir
   *
   * (Only updated if the last updated time of the item is different with Steam Cloud or the workitem isn't existed in local).
   */
  ugcSynchronizeItems: (
    options: { app_id: number; page_num: number },
    sync_dir: string,
    success_callback: (items: { SteamUGCDetails: SteamUGCDetails; isUpdated: boolean }[]) => void,
    error_callback?: ErrorCallback
  ) => void;
  ugcUnsubscribe: (published_file_handle: string, success_callback: () => void, error_callback?: ErrorCallback) => void;
  /**
   * Shows the Steam overlay pointed to Steam's workshop page or to the specified workshop item.
   */
  ugcShowOverlay: (published_file_id?: string) => void;
  /**
   * Fetches the greenworks.UGCItemState of the specified workshop item.
   */
  ugcGetItemState: (published_file_id: string) => void;
  /**
   * Fetches a workshop item's install information if its state includes greenworks.UGCItemState.Installed.
   * Returns undefined if the information could not be fetched, otherwise an object containing the following properties:
   * @property {string} sizeOnDisk: Represents uint64, the size of the item on disk
   * @property {string} folder: Path to the item's directory on disk, if state is LegacyItem this points to the file itself
   * @property {number} timestamp: Returns the time when the item was last updated
   */
  ugcGetItemInstallInfo: (
    published_file_id: string
  ) => undefined | { sizeOnDisk: string; folder: string; timestamp: number };
  /**
   * Writes mutilple local files to Steam Cloud.
   */
  saveFilesToCloud: (files_path: string[], success_callback: () => void, error_callback?: ErrorCallback) => void;
  /**
   * Publishes file_path workshop item on Steam.
   *
   * The files file_path and image_path need to be existed on Steam Cloud
   * (Using writeTextToFile or saveFilesToCloud API) and get shared
   * (Using Greenworks.fileShare) first.
   *
   * An empty string of image_path means no image for the workshp item.
   */
  publishWorkshopFile: (
    options: { app_id: number; tags: string[] },
    file_path: string,
    image_path: string,
    title: string,
    description: string,
    success_callback: (publish_file_handle: string) => void,
    error_callback?: ErrorCallback
  ) => void;
  /**
   * An empty string of file_path/image_path/title/description means no update of that field.
   */
  updatePublishedWorkshopFile: (
    options: { tags: string[] },
    published_file_handle: string,
    file_path: string,
    image_path: string,
    title: string,
    description: string,
    success_callback: () => void,
    error_callback?: ErrorCallback
  ) => void;
  /**
   * Publishes user generated content(ugc) to Steam workshop.
   */
  ugcPublish: (
    file_name: string,
    title: string,
    description: string,
    image_name: string,
    success_callback: (published_file_handle: string) => void,
    error_callback?: ErrorCallback,
    progress_callback?: (progress_msg: string) => void
  ) => void;
  /**
   * Updates published ugc.
   */
  ugcPublishUpdate: (
    published_file_id: string,
    file_name: string,
    title: string,
    description: string,
    image_name: string,
    success_callback: (published_file_handle: string) => void,
    error_callback?: ErrorCallback,
    progress_callback?: (progress_msg: string) => void
  ) => void;
  Utils: {
    /**
     * Moves source_dir to target_dir.
     */
    move: (
      source_dir: string,
      target_dir: string,
      success_callback: () => void,
      error_callback?: ErrorCallback
    ) => void;
    /**
     * Creates a zip archive of source_dir.
     */
    createArchive: (
      zip_file_path: string,
      source_dir: string,
      password: string,
      compress_level: number,
      success_callback: () => void,
      error_callback?: ErrorCallback
    ) => void;
    /**
     * Extracts the zip_file_path to the specified extract_dir.
     */
    extractArchive: (
      zip_file_path: string,
      extract_dir: string,
      password: string,
      success_callback: () => void,
      error_callback?: ErrorCallback
    ) => void;
  };
  /**
   * Returns a Integer represents the value of the user stat.
   */
  getStatInt: (name: string) => number;
  /**
   * Returns a Float represents the value of the user stat.
   */
  getStatFloat: (name: string) => number;
  /**
   * Returns a Boolean indicates whether the method succeeds.
   */
  setStat: (name: string, value: number) => boolean;
  /**
   * Stores the current user stats data on the server.
   */
  storeStats: (success_callback: (game_id: number) => void, error_callback?: ErrorCallback) => void;
  _steam_events: Steamevents;
  EncryptedAppTicketSymmetricKeyLength: number;
  FriendFlags: FriendFlags;
  FriendRelationship: FriendRelationship;
  PersonaChange: PersonaChange;
  AccountType: AccountType;
  ChatEntryType: ChatEntryType;
  ChatMemberStateChange: ChatMemberStateChange;
  LobbyComparison: LobbyComparison;
  LobbyDistanceFilter: LobbyDistanceFilter;
  LobbyType: LobbyType;
  Result: Result;
  _version: string;
  UGCMatchingType: UGCMatchingType;
  UGCQueryType: UGCQueryType;
  UserUGCListSortOrder: UserUGCListSortOrder;
  UserUGCList: UserUGCList;
  UGCItemState: UGCItemState;
  _events: Steamevents;
  _eventsCount: number;
}

/**
 * Represents Steam SDK SteamUGCDetails_t(return by greenworks.ugcGetItems), details for a single published file/UGC
 * @param {*} acceptForUse:  Boolean: Whether is flaged as accepted in Steam workshop.
 * @param {*} banned:  Boolean: Whether is banned
 * @param {*} tagsTruncated:  Boolean: Whether the list of tags is too long to be returned in provided buffer.
 * @param {*} fileType:  Integer: Type of the file
 * @param {*} result:  Integer: Result of the operation. (1: Success, Others: Fail)
 * @param {*} visibility:  Integer: the visiblility of the file (0: Public, 1: FriendsOnly, 2: Private)
 * @param {*} score:  Double: Calculated score
 * @param {*} file:  String: Represents uint64, file handle
 * @param {*} fileName:  String: Cloud file name of the primary file
 * @param {*} fileSize:  Integer: Size of the primary file
 * @param {*} previewFile:  String: Represents uint64, handle of preview file
 * @param {*} previewFileSize:  Integer: Size of preview file
 * @param {*} steamIDOwner:  String: Represents uint64, Steam ID of user who created the file.
 * @param {*} consumerAppID:  Integer: ID of app that consumes the file
 * @param {*} creatorAppID:  Integer: ID of app that created the file
 * @param {*} publishedFileId:  String: Represents uint64, the file ID
 * @param {*} title:  String: Title of the file
 * @param {*} description:  String: Description of the file
 * @param {*} URL:  String:
 * @param {*} tags:  String: List of tags, separated by comma.
 * @param {*} timeAddedToUserList:  Integer: Time when user added this file to list.
 * @param {*} timeCreated:  Integer: Time when the file was created
 * @param {*} timeUpdated:  Integer: Time when the file is last updated.
 * @param {*} votesDown:  Integer: Number of votes down
 * @param {*} votesUp:  Integer: Number of votes up
 */
interface SteamUGCDetails {
  acceptForUse: boolean;
  banned: boolean;
  tagsTruncated: boolean;
  fileType: number;
  result: number;
  visibility: number;
  score: number;
  file: string;
  fileName: string;
  fileSize: number;
  previewFile: string;
  previewFileSize: number;
  steamIDOwner: string;
  consumerAppID: number;
  creatorAppID: number;
  publishedFileId: string;
  title: string;
  description: string;
  URL: string;
  tags: string;
  timeAddedToUserList: number;
  timeCreated: number;
  timeUpdated: number;
  votesDown: number;
  votesUp: number;
}
interface UGCItemState {
  None: number;
  Subscribed: number;
  LegacyItem: number;
  Installed: number;
  NeedsUpdate: number;
  Downloading: number;
  DownloadPending: number;
}
interface UserUGCList {
  Published: number;
  VotedOn: number;
  VotedUp: number;
  VotedDown: number;
  WillVoteLater: number;
  Favorited: number;
  Subscribed: number;
  UsedOrPlayer: number;
  Followed: number;
}
interface UserUGCListSortOrder {
  CreationOrderDesc: number;
  CreationOrderAsc: number;
  TitleAsc: number;
  LastUpdatedDesc: number;
  SubscriptionDateDesc: number;
  VoteScoreDesc: number;
  ForModeration: number;
}
interface UGCQueryType {
  RankedByVote: number;
  RankedByPublicationDate: number;
  AcceptedForGameRankedByAcceptanceDate: number;
  RankedByTrend: number;
  FavoritedByFriendsRankedByPublicationDate: number;
  CreatedByFriendsRankedByPublicationDate: number;
  RankedByNumTimesReported: number;
  CreatedByFollowedUsersRankedByPublicationDate: number;
  NotYetRated: number;
  RankedByTotalVotesAsc: number;
  RankedByVotesUp: number;
  RankedByTextSearch: number;
}
interface UGCMatchingType {
  Items: number;
  ItemsMtx: number;
  ItemsReadyToUse: number;
  Collections: number;
  Artwork: number;
  Videos: number;
  Screenshots: number;
  AllGuides: number;
  WebGuides: number;
  IntegratedGuides: number;
  UsableInGame: number;
  ControllerBindings: number;
}
interface Result {
  OK: number;
  Fail: number;
  NoConnection: number;
  InvalidPassword: number;
  LoggedInElsewhere: number;
  InvalidProtocolVer: number;
  InvalidParam: number;
  FileNotFound: number;
  Busy: number;
  InvalidState: number;
  InvalidName: number;
  InvalidEmail: number;
  DuplicateName: number;
  AccessDenied: number;
  Timeout: number;
  Banned: number;
  AccountNotFound: number;
  InvalidSteamID: number;
  ServiceUnavailable: number;
  NotLoggedOn: number;
  Pending: number;
  EncryptionFailure: number;
  InsufficientPrivilege: number;
  LimitExceeded: number;
  Revoked: number;
  Expired: number;
  AlreadyRedeemed: number;
  DuplicateRequest: number;
  AlreadyOwned: number;
  IPNotFound: number;
  PersistFailed: number;
  LockingFailed: number;
  LogonSessionReplaced: number;
  ConnectFailed: number;
  HandshakeFailed: number;
  IOFailure: number;
  RemoteDisconnect: number;
  ShoppingCartNotFound: number;
  Blocked: number;
  Ignored: number;
  NoMatch: number;
  AccountDisabled: number;
  ServiceReadOnly: number;
  AccountNotFeatured: number;
  AdministratorOK: number;
  ContentVersion: number;
  TryAnotherCM: number;
  PasswordRequiredToKickSession: number;
  AlreadyLoggedInElsewhere: number;
  Suspended: number;
  Cancelled: number;
  DataCorruption: number;
  DiskFull: number;
  RemoteCallFailed: number;
  PasswordUnset: number;
  ExternalAccountUnlinked: number;
  PSNTicketInvalid: number;
  ExternalAccountAlreadyLinked: number;
  RemoteFileConflict: number;
  IllegalPassword: number;
  SameAsPreviousValue: number;
  AccountLogonDenied: number;
  CannotUseOldPassword: number;
  InvalidLoginAuthCode: number;
  AccountLogonDeniedNoMail: number;
  HardwareNotCapableOfIPT: number;
  IPTInitError: number;
  ParentalControlRestricted: number;
  FacebookQueryError: number;
  ExpiredLoginAuthCode: number;
  IPLoginRestrictionFailed: number;
  AccountLockedDown: number;
  AccountLogonDeniedVerifiedEmailRequired: number;
  NoMatchingURL: number;
  BadResponse: number;
  RequirePasswordReEntry: number;
  ValueOutOfRange: number;
  UnexpectedError: number;
  Disabled: number;
  InvalidCEGSubmission: number;
  RestrictedDevice: number;
  RegionLocked: number;
  RateLimitExceeded: number;
  AccountLoginDeniedNeedTwoFactor: number;
  ItemDeleted: number;
  AccountLoginDeniedThrottle: number;
  TwoFactorCodeMismatch: number;
  TwoFactorActivationCodeMismatch: number;
  AccountAssociatedToMultiplePartners: number;
  NotModified: number;
  NoMobileDevice: number;
  TimeNotSynced: number;
  SmsCodeFailed: number;
  AccountLimitExceeded: number;
  AccountActivityLimitExceeded: number;
  PhoneActivityLimitExceeded: number;
  RefundToWallet: number;
  EmailSendFailure: number;
  NotSettled: number;
  NeedCaptcha: number;
  GSLTDenied: number;
  GSOwnerDenied: number;
  InvalidItemType: number;
  IPBanned: number;
  GSLTExpired: number;
  InsufficientFunds: number;
  TooManyPending: number;
}
interface LobbyType {
  Private: number;
  FriendsOnly: number;
  Public: number;
  Invisible: number;
}
interface LobbyDistanceFilter {
  Close: number;
  Default: number;
  Far: number;
  Worldwide: number;
}
interface LobbyComparison {
  EqualToOrLessThan: number;
  LessThan: number;
  Equal: number;
  GreaterThan: number;
  EqualToOrGreaterThan: number;
  NotEqual: number;
}
interface ChatMemberStateChange {
  Entered: number;
  Left: number;
  Disconnected: number;
  Kicked: number;
  Banned: number;
}
interface ChatEntryType {
  Invalid: number;
  ChatMsg: number;
  Typing: number;
  InviteGame: number;
  Emote: number;
  LeftConversation: number;
  Entered: number;
  WasKicked: number;
  WasBanned: number;
  Disconnected: number;
  HistoricalChat: number;
  LinkBlocked: number;
}
interface AccountType {
  Invalid: number;
  Individual: number;
  Multiseat: number;
  GameServer: number;
  AnonymousGameServer: number;
  Pending: number;
  ContentServer: number;
  Clan: number;
  Chat: number;
  ConsoleUser: number;
  AnonymousUser: number;
}
interface PersonaChange {
  Name: number;
  Status: number;
  ComeOnline: number;
  GoneOffline: number;
  GamePlayed: number;
  GameServer: number;
  Avatar: number;
  JoinedSource: number;
  LeftSource: number;
  RelationshipChanged: number;
  NameFirstSet: number;
  NickName: number;
  SteamLevel: number;
}
interface FriendRelationship {
  None: number;
  Blocked: number;
  RequestRecipient: number;
  Friend: number;
  RequestInitiator: number;
  Ignored: number;
  IgnoredFriend: number;
  Suggested: number;
}
interface FriendFlags {
  None: number;
  Blocked: number;
  FriendshipRequested: number;
  Immediate: number;
  ClanMember: number;
  OnGameServer: number;
  RequestingFriendship: number;
  RequestingInfo: number;
  Ignored: number;
  IgnoredFriend: number;
  ChatMember: number;
  All: number;
}
interface Steamevents {}
