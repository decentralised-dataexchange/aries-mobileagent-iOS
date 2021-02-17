typedef NS_ENUM(NSInteger, IndyErrorCode)
{
    IndyError_Success = 0,
    
    // Common errors
    
    // Caller passed invalid value as param 1 (null, invalid json and etc..)
    IndyError_CommonInvalidParam1 = 100,
    
    // Caller passed invalid value as param 2 (null, invalid json and etc..)
    IndyError_CommonInvalidParam2 = 101,
    
    // Caller passed invalid value as param 3 (null, invalid json and etc..)
    IndyError_CommonInvalidParam3 = 102,
    
    // Caller passed invalid value as param 4 (null, invalid json and etc..)
    IndyError_CommonInvalidParam4 = 103,
    
    // Caller passed invalid value as param 5 (null, invalid json and etc..)
    IndyError_CommonInvalidParam5 = 104,
    
    // Caller passed invalid value as param 6 (null, invalid json and etc..)
    IndyError_CommonInvalidParam6 = 105,
    
    // Caller passed invalid value as param 7 (null, invalid json and etc..)
    IndyError_CommonInvalidParam7 = 106,
    
    // Caller passed invalid value as param 8 (null, invalid json and etc..)
    IndyError_CommonInvalidParam8 = 107,
    
    // Caller passed invalid value as param 9 (null, invalid json and etc..)
    IndyError_CommonInvalidParam9 = 108,
    
    // Caller passed invalid value as param 10 (null, invalid json and etc..)
    IndyError_CommonInvalidParam10 = 109,
    
    // Caller passed invalid value as param 11 (null, invalid json and etc..)
    IndyError_CommonInvalidParam11 = 110,
    
    // Caller passed invalid value as param 12 (null, invalid json and etc..)
    IndyError_CommonInvalidParam12 = 111,
    
    // Invalid library state was detected in runtime. It signals library bug
    IndyError_CommonInvalidState = 112,
    
    // Object (json, config, key, credential and etc...) passed by library caller has invalid structure
    IndyError_CommonInvalidStructure = 113,
    
    // IO Error
    IndyError_CommonIOError = 114,

    // Caller passed invalid value as param 13 (null, invalid json and etc..)
    IndyError_CommonInvalidParam13 = 115,

    // Caller passed invalid value as param 14 (null, invalid json and etc..)
    IndyError_CommonInvalidParam14 = 116,

    // Wallet errors
    // Caller passed invalid wallet handle
    IndyError_WalletInvalidHandle = 200,

    // Unknown type of wallet was passed on create_wallet
    IndyError_WalletUnknownTypeError = 201,

    // Attempt to register already existing wallet type
    IndyError_WalletTypeAlreadyRegisteredError = 202,

    // Attempt to create wallet with name used for another exists wallet
    IndyError_WalletAlreadyExistsError = 203,

    // Requested entity id isn't present in wallet
    IndyError_WalletNotFoundError = 204,

    // Trying to use wallet with pool that has different name
    IndyError_WalletIncompatiblePoolError = 205,

    // Trying to open wallet that was opened already
    IndyError_WalletAlreadyOpenedError = 206,

    // Attempt to open encrypted wallet with invalid credentials
    IndyError_WalletAccessFailed = 207,

    // Input provided to wallet operations is considered not valid
    IndyError_WalletInputError = 208,

    // Decoding of wallet data during input/output failed
    IndyError_WalletDecodingError = 209,

    // Storage error occurred during wallet operation
    IndyError_WalletStorageError = 210,

    // Error during encryption-related operations
    IndyError_WalletEncryptionError = 211,

    // Requested wallet item not found
    IndyError_WalletItemNotFound = 212,

    // Returned if wallet's add_record operation is used with record name that already exists
    IndyError_WalletItemAlreadyExists = 213,

    // Returned if provided wallet query is invalid
    IndyError_WalletQueryError = 214,
    
    // Ledger errors
    // Trying to open pool ledger that wasn't created before
    IndyError_PoolLedgerNotCreatedError = 300,
    
    // Caller passed invalid pool ledger handle
    IndyError_PoolLedgerInvalidPoolHandle = 301,
    
    // Pool ledger terminated
    IndyError_PoolLedgerTerminated = 302,
    
    // No concensus during ledger operation
    IndyError_LedgerNoConsensusError = 303,

    // Attempt to parse invalid transaction response
    IndyError_LedgerInvalidTransaction = 304,

    // Attempt to send transaction without the necessary privileges
    IndyError_LedgerSecurityError = 305,
    
    // Attempt to create pool ledger config with name used for another existing pool
    IndyError_PoolLedgerConfigAlreadyExistsError = 306,

    // Timeout for action
    IndyError_PoolLedgerTimeout = 307,

    // Attempt to open Pool for witch Genesis Transactions are not compatible with set Protocol version.
    // Call pool.indy_set_protocol_version to set correct Protocol version.
    IndyError_PoolIncompatibleProtocolVersion = 308,

    // Item not found on ledger.
    IndyError_LedgerNotFound = 309,

    // Revocation registry is full and creation of new registry is necessary
    IndyError_AnoncredsRevocationRegistryFullError = 400,
    
    IndyError_AnoncredsInvalidUserRevocId = 401,
    
    IndyError_AnoncredsAccumulatorIsFull = 402,

    // Attempt to generate master secret with duplicated name
    IndyError_AnoncredsMasterSecretDuplicateNameError = 404,
    
    IndyError_AnoncredsProofRejected = 405,

    IndyError_AnoncredsCredentialRevoked = 406,

    // Attempt to create credential definition with duplicated did schema pair
    IndyError_AnoncredsCredDefAlreadyExistsError = 407,

    // Crypto errors
    // Unknown format of DID entity keys
    IndyError_UnknownCryptoTypeError = 500,

    // Attempt to create duplicate did
    IndyError_DidAlreadyExistsError = 600,

    // Unknown payment method was given
    IndyError_PaymentUnknownMethodError = 700,

    // No method were scraped from inputs/outputs or more than one were scraped
    IndyError_PaymentIncompatibleMethodsError = 701,

    // Insufficient funds on inputs
    IndyError_PaymentInsufficientFundsError = 702,

    // No such source on a ledger
    IndyError_PaymentSourceDoesNotExistError = 703,

    // Operation is not supported for payment method
    IndyError_PaymentOperationNotSupportedError = 704,

    // Extra funds on inputs
    IndyError_PaymentExtraFundsError = 705,

    // The transaction is not allowed to a requester
    IndyError_TransactionNotAllowedError = 706
};
