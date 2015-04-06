module Handler.Uszata where

import Import

getHomeR :: Handler Html
getHomeR = do
  defaultLayout $ do
    setTitle "Uszata strona"
    $(widgetFile "homepage")

getPoradnikR :: Handler Html
getPoradnikR = do
  tileLayout $ do
    setTitle "Poradnik użytkownika - Uszata strona"
    $(widgetFile "poradnik")

getMieszkanieR :: Handler Html
getMieszkanieR = do
  defaultLayout $ do
    setTitle "Jak przygotować mieszkanie? - Uszata strona"
    $(widgetFile "poradnik-mieszkanie")
