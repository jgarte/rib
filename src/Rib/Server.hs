{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

-- | Serve generated static files with HTTP
module Rib.Server
  (
    serve
  , getHTMLFileUrl
  )
where

import Prelude hiding (init, last)

import Data.Text (Text)
import qualified Data.Text as T

import Development.Shake.FilePath ((-<.>))
import Network.Wai.Application.Static (defaultFileServerSettings, ssListing, ssLookupFile, staticApp)
import qualified Network.Wai.Handler.Warp as Warp
import WaiAppStatic.Types (StaticSettings)

-- | WAI Settings suited for serving statically generated websites.
staticSiteServerSettings :: FilePath -> StaticSettings
staticSiteServerSettings root = settings
  { ssLookupFile = ssLookupFile settings
  , ssListing = Nothing  -- Disable directory listings
  }
  where
    settings = defaultFileServerSettings root

-- | Return the URL for the given @.html@ file under serve directory
--
-- File path must be relative to the serve directory.
--
-- You may also pass source paths as long as they map directly to destination
-- path except for file extension.
getHTMLFileUrl
  :: FilePath
  -- ^ Relative path to a page (extension is ignored)
  -> Text
getHTMLFileUrl path = T.pack $ "/" ++  (path -<.> ".html")

-- | Run a HTTP server to serve a directory of static files
--
-- Allow URLs of the form @//foo//bar@ to serve @${path}//foo//bar.html@
serve
  :: Int
  -- ^ Port number to bind to
  -> FilePath
  -- ^ Directory to serve.
  -> IO ()
serve port path = do
  putStrLn $ "[Rib] Serving at http://localhost:" <> show port
  Warp.run port $ staticApp $ staticSiteServerSettings path
