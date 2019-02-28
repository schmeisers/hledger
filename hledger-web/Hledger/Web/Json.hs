{-# OPTIONS_GHC -fno-warn-orphans #-}

--{-# LANGUAGE CPP                 #-}
--{-# LANGUAGE DataKinds           #-}
--{-# LANGUAGE DeriveAnyClass      #-}
{-# LANGUAGE DeriveGeneric       #-}
--{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances   #-}
--{-# LANGUAGE NamedFieldPuns #-}
--{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE OverloadedStrings #-}
--{-# LANGUAGE PolyKinds           #-}
--{-# LANGUAGE QuasiQuotes         #-}
--{-# LANGUAGE QuasiQuotes #-}
--{-# LANGUAGE Rank2Types #-}
--{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
--{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE StandaloneDeriving #-}
--{-# LANGUAGE TemplateHaskell       #-}
--{-# LANGUAGE TypeFamilies        #-}
--{-# LANGUAGE TypeOperators       #-}

module Hledger.Web.Json ( 
  -- * Instances
  -- * Utilities
   readJsonFile
  ,writeJsonFile
) where

import           Data.Aeson
--import           Data.Aeson.TH
import qualified Data.ByteString.Lazy as BL
import           Data.Decimal
import           Data.Maybe
import           GHC.Generics (Generic)

import           Hledger.Data

-- JSON instances. See also hledger-api.
-- Should they be in hledger-lib Types.hs ?

-- To JSON

instance ToJSON Status
instance ToJSON GenericSourcePos
instance ToJSON Decimal
instance ToJSON Amount
instance ToJSON AmountStyle
instance ToJSON Side
instance ToJSON DigitGroupStyle
instance ToJSON MixedAmount
instance ToJSON BalanceAssertion
instance ToJSON Price
instance ToJSON MarketPrice
instance ToJSON PostingType
instance ToJSON Posting where
  toJSON Posting{..} = object
    ["pdate"             .= toJSON pdate
    ,"pdate2"            .= toJSON pdate2
    ,"pstatus"           .= toJSON pstatus
    ,"paccount"          .= toJSON paccount
    ,"pamount"           .= toJSON pamount
    ,"pcomment"          .= toJSON pcomment
    ,"ptype"             .= toJSON ptype
    ,"ptags"             .= toJSON ptags
    ,"pbalanceassertion" .= toJSON pbalanceassertion
    -- To avoid a cycle, show just the parent transaction's index number 
    -- in a dummy field. When re-parsed, there will be no parent.
    ,"ptransaction_"     .= toJSON (maybe "" (show.tindex) ptransaction)
    -- This is probably not wanted in json, we discard it.
    ,"poriginal"         .= toJSON (Nothing :: Maybe Posting) 
    ]
instance ToJSON Transaction
instance ToJSON Account where
  toJSON a = object
    ["aname"        .= toJSON (aname a)
    ,"aebalance"    .= toJSON (aebalance a)
    ,"aibalance"    .= toJSON (aibalance a)
    ,"anumpostings" .= toJSON (anumpostings a)
    ,"aboring"      .= toJSON (aboring a)
    -- To avoid a cycle, show just the parent account's name 
    -- in a dummy field. When re-parsed, there will be no parent.
    ,"aparent_"     .= toJSON (maybe "" aname $ aparent a)
    -- To avoid a cycle, drop the subaccounts, showing just their names
    -- in a dummy field. When re-parsed, there will be no subaccounts.
    ,"asubs"        .= toJSON ([]::[Account])
    ,"asubs_"       .= toJSON (map aname $ asubs a)
    ]

-- From JSON

instance FromJSON Status
instance FromJSON GenericSourcePos
instance FromJSON Amount
instance FromJSON AmountStyle
instance FromJSON Side
instance FromJSON DigitGroupStyle
instance FromJSON MixedAmount
instance FromJSON BalanceAssertion
instance FromJSON Price
instance FromJSON MarketPrice
instance FromJSON PostingType
instance FromJSON Posting
instance FromJSON Transaction
instance FromJSON AccountDeclarationInfo
instance FromJSON Account

-- Decimal, various attempts
--
-- https://stackoverflow.com/questions/40331851/haskell-data-decimal-as-aeson-type
----instance FromJSON Decimal where parseJSON = 
----  A.withScientific "Decimal" (return . right . eitherFromRational . toRational)
--
-- https://github.com/bos/aeson/issues/474
-- http://hackage.haskell.org/package/aeson-1.4.2.0/docs/Data-Aeson-TH.html
-- $(deriveFromJSON defaultOptions ''Decimal) -- doesn't work
-- $(deriveFromJSON defaultOptions ''DecimalRaw)  -- works; requires TH, but gives better parse error messages
--
-- https://github.com/PaulJohnson/Haskell-Decimal/issues/6
--deriving instance Generic Decimal
--instance FromJSON Decimal
deriving instance Generic (DecimalRaw Integer)
instance FromJSON (DecimalRaw Integer)
--
-- @simonmichael, I think the code in your first comment should work if it compiles—though “work” doesn’t mean you can parse a JSON number directly into a `Decimal` using the generic instance, as you’ve discovered.
--
--Error messages with these extensions are always rather cryptic, but I’d prefer them to Template Haskell. Typically you’ll want to start by getting a generic `ToJSON` instance working, then use that to figure out what the `FromJSON` instance expects to parse: for a correct instance, `encode` and `decode` should give you an isomorphism between your type and a subset of `Bytestring` (up to the `Maybe` wrapper that `decode` returns).
--
--I don’t have time to test it right now, but I think it will also work without `DeriveAnyClass`, just using `DeriveGeneric` and `StandAloneDeriving`. It should also work to use the [`genericParseJSON`](http://hackage.haskell.org/package/aeson/docs/Data-Aeson.html#v:genericParseJSON) function to implement the class explicitly, something like this:
--
--{-# LANGUAGE DeriveGeneric #-}
--{-# LANGUAGE StandAloneDeriving #-}
--import GHC.Generics
--import Data.Aeson
--deriving instance Generic Decimal
--instance FromJSON Decimal where
--  parseJSON = genericParseJSON defaultOptions
--
--And of course you can avoid `StandAloneDeriving` entirely if you’re willing to wrap `Decimal` in your own `newtype`.


-- Utilities

-- | Read a json from a file and decode/parse it as the target type, if we can.
-- Example:
-- >>> readJsonFile "in.json" :: IO MixedAmount
readJsonFile :: FromJSON a => FilePath -> IO a
readJsonFile f = do
  bs <- BL.readFile f
  let v = fromMaybe (error "could not decode bytestring as json value") (decode bs :: Maybe Value) 
  case fromJSON v :: FromJSON a => Result a of
    Error e   -> error e
    Success t -> return t

-- | Write some to-JSON-convertible haskell value to a json file, if we can.
-- Example:
-- >>> writeJsonFile "out.json" nullmixedamt
writeJsonFile :: ToJSON a => FilePath -> a -> IO ()
writeJsonFile f v = BL.writeFile f (encode $ toJSON v)
