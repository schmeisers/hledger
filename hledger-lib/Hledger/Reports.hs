{-# LANGUAGE OverloadedStrings, RecordWildCards, DeriveDataTypeable, FlexibleInstances #-}
{-|

Generate several common kinds of report from a journal, as \"*Report\" -
simple intermediate data structures intended to be easily rendered as
text, html, json, csv etc. by hledger commands, hamlet templates,
javascript, or whatever.

-}

module Hledger.Reports (
  module Hledger.Reports.ReportOptions,
  module Hledger.Reports.ReportTypes,
  module Hledger.Reports.EntriesReport,
  module Hledger.Reports.PostingsReport,
  module Hledger.Reports.TransactionsReports,
  module Hledger.Reports.BalanceReport,
  module Hledger.Reports.MultiBalanceReports,
  module Hledger.Reports.BudgetReport,
--   module Hledger.Reports.BalanceHistoryReport,
  -- * Tests
  tests_Reports
)
where

import Hledger.Reports.ReportOptions
import Hledger.Reports.ReportTypes
import Hledger.Reports.EntriesReport
import Hledger.Reports.PostingsReport
import Hledger.Reports.TransactionsReports
import Hledger.Reports.BalanceReport
import Hledger.Reports.MultiBalanceReports
import Hledger.Reports.BudgetReport
-- import Hledger.Reports.BalanceHistoryReport
import Hledger.Utils.Test

tests_Reports = tests "Reports" [
   tests_BalanceReport
  ,tests_BudgetReport
  ,tests_EntriesReport
  ,tests_MultiBalanceReports
  ,tests_PostingsReport
  ,tests_ReportOptions
  ,tests_TransactionsReports
  ]
