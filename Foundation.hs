module Foundation where

import Database.Persist.MongoDB hiding (master)
import Import.NoFoundation
import Text.Hamlet                 (hamletFile)
import Text.Jasmine                (minifym)
import Yesod.Auth.BrowserId        (authBrowserId)
import Yesod.Core.Types            (Logger)
import Yesod.Default.Util          (addStaticContentExternal)
import qualified Yesod.Core.Unsafe as Unsafe

data LayoutType = TileLayout | ContentLayout | HomeLayout | DefaultLayout deriving Enum

-- | The foundation datatype for your application. This can be a good place to
-- keep settings and values requiring initialization before your application
-- starts running, such as database connections. Every handler will have
-- access to the data present here.
data App = App
    { appSettings    :: AppSettings
    , appStatic      :: Static -- ^ Settings for static file serving.
    , appConnPool    :: ConnectionPool -- ^ Database connection pool.
    , appHttpManager :: Manager
    , appLogger      :: Logger
    }

instance HasHttpManager App where
    getHttpManager = appHttpManager

-- This is where we define all of the routes in our application. For a full
-- explanation of the syntax, please see:
-- http://www.yesodweb.com/book/routing-and-handlers
--
-- Note that this is really half the story; in Application.hs, mkYesodDispatch
-- generates the rest of the code. Please see the linked documentation for an
-- explanation for this split.
mkYesodData "App" $(parseRoutesFile "config/routes")

-- | A convenient synonym for creating forms.
type Form x = Html -> MForm (HandlerT App IO) (FormResult x, Widget)

-- Please see the documentation for the Yesod typeclass. There are a number
-- of settings which can be configured by overriding methods here.
instance Yesod App where
    -- Controls the base of generated URLs. For more information on modifying,
    -- see: https://github.com/yesodweb/yesod/wiki/Overriding-approot
    approot = ApprootMaster $ appRoot . appSettings

    -- Store session data on the client in encrypted cookies,
    -- default session idle timeout is 120 minutes
    makeSessionBackend _ = fmap Just $ defaultClientSessionBackend
        120    -- timeout in minutes
        "config/client_session_key.aes"

    defaultLayout widget = genericLayout "home" DefaultLayout $(widgetFile "layout-default") widget

    -- The page to be redirected to when authentication is required.
    authRoute _ = Just $ HomeR

    -- Routes not requiring authentication.
    isAuthorized _ _ = return Authorized

    -- This function creates static content files in the static folder
    -- and names them based on a hash of their content. This allows
    -- expiration dates to be set far in the future without worry of
    -- users receiving stale content.
    addStaticContent ext mime content = do
        master <- getYesod
        let staticDir = appStaticDir $ appSettings master
        addStaticContentExternal
            minifym
            genFileName
            staticDir
            (StaticR . flip StaticRoute [])
            ext
            mime
            content
      where
        -- Generate a unique filename based on the content itself
        genFileName lbs = "autogen-" ++ base64md5 lbs

    -- What messages should be logged. The following includes all messages when
    -- in development, and warnings and errors in production.
    shouldLog app _source level =
        appShouldLogAll (appSettings app)
            || level == LevelWarn
            || level == LevelError

    makeLogger = return . appLogger

-- How to run database actions.
instance YesodPersist App where
    type YesodPersistBackend App = MongoContext
    runDB action = do
        master <- getYesod
        runMongoDBPool
            (mgAccessMode $ appDatabaseConf $ appSettings master)
            action
            (appConnPool master)

instance YesodAuth App where
    type AuthId App = UserId

    -- Where to send a user after successful login
    loginDest _ = HomeR
    -- Where to send a user after logout
    logoutDest _ = HomeR
    -- Override the above two destinations when a Referer: header is present
    redirectToReferer _ = True

    getAuthId creds = runDB $ do
        x <- getBy $ UniqueUser $ credsIdent creds
        case x of
            Just (Entity uid _) -> return $ Just uid
            Nothing -> do
                fmap Just $ insert User
                    { userIdent = credsIdent creds
                    , userPassword = Nothing
                    }

    -- You can add other plugins like BrowserID, email or OAuth here
    authPlugins _ = [authBrowserId def]

    authHttpManager = getHttpManager

instance YesodAuthPersist App

-- This instance is required to use forms. You can modify renderMessage to
-- achieve customized and internationalized form validation messages.
instance RenderMessage App FormMessage where
    renderMessage _ _ = defaultFormMessage

unsafeHandler :: App -> Handler a -> IO a
unsafeHandler = Unsafe.fakeHandlerGetLogger appLogger

-- Custom layout support
genericLayout :: String -> LayoutType -> WidgetT App IO () -> w -> HandlerT App IO Html
genericLayout curPage layoutType layoutFile widget = do
    master <- getYesod
    mmsg <- getMessage
    pc <- widgetToPageContent $ layoutFile
    bodyClass <- case layoutType of
        ContentLayout -> return ("single single-project" :: String)  -- ':: String' is necessary because otherwise GHC can't figure out the type
        _             -> return "home page page-template-portfolio"
    withUrlRenderer $(hamletFile "templates/default-layout-wrapper.hamlet")

tileLayout :: ToWidget App w => String -> w -> HandlerT App IO Html
tileLayout curPage widget = genericLayout curPage TileLayout $(widgetFile "layout-tile") widget

contentLayout :: ToWidget App w => String -> w -> HandlerT App IO Html
contentLayout curPage widget = genericLayout curPage ContentLayout $(widgetFile "layout-content") widget

-- Main menu
getMainMenu :: [(Route App, String, Html)]
getMainMenu = [(HomeR, "home", "Strona główna"),
               (PoradnikR, "poradnik", "Poradnik opiekuna"),
               (HomeR, "organizacje", "Organizacje adopcyjne"),
               (HomeR, "apel", "Apel"),
               (HomeR, "prawa", "Prawa zwierząt"),
               (HomeR, "wege", "Wegetarianizm"),
               (HomeR, "linki", "Linki i literatura"),
               (HomeR, "galeria", "Galeria Uszatej"),
               (HomeR, "o-stronie", "O stronie")]

-- Accessors for 3-element tuples (because that's what getMainMenu returns).
fst3 :: (t1, t2, t3) -> t1
fst3 (t1, _, _) = t1

snd3 :: (t1, t2, t3) -> t2
snd3 (_, t2, _) = t2

trd3 :: (t1, t2, t3) -> t3
trd3 (_, _, t3) = t3
