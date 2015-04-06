module Handler.Uszata where

import Import

getPoradnikR :: Handler Html
getPoradnikR = do
    defaultLayout $ do
        setTitle "Poradnik użytkownika"
        $(widgetFile "poradnik")

getMieszkanieR :: Handler Html
getMieszkanieR = do
    defaultLayout $ do
        setTitle "Jak przygotować mieszkanie?"
        $(widgetFile "poradnik-mieszkanie")
