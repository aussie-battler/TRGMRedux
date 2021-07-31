export = greenworks;
declare var greenworks: GreenWorks;
interface GreenWorks {
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
