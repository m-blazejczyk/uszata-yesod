module Handler.Uszata where

import Import

getHomeR :: Handler Html
getHomeR = do
  defaultLayout $ do
    setTitle "Uszata strona"
    $(widgetFile "homepage")

getPoradnikR :: Handler Html
getPoradnikR = do
  tileLayout "poradnik" $ do
    setTitle "Poradnik użytkownika - Uszata strona"
    $(widgetFile "poradnik")

getMieszkanieR :: Handler Html
getMieszkanieR = do
  contentLayout "poradnik" $ do
    setTitle "Jak przygotować mieszkanie? - Poradnik użytkownika - Uszata strona"
    $(widgetFile "poradnik-mieszkanie")

getSkadWziacR :: Handler Html
getSkadWziacR = do
  contentLayout "poradnik" $ do
    setTitle "Skąd wziąć królika? - Poradnik użytkownika - Uszata strona"
    $(widgetFile "poradnik-skad-wziac")

getPrzynoszenieR :: Handler Html
getPrzynoszenieR = do
  contentLayout "poradnik" $ do
    setTitle "Przynoszenie do domu - Poradnik użytkownika - Uszata strona"
    $(widgetFile "poradnik-przynoszenie")

getDlaDzieckaR :: Handler Html
getDlaDzieckaR = do
  contentLayout "poradnik" $ do
    setTitle "Królik dla dziecka? - Poradnik użytkownika - Uszata strona"
    $(widgetFile "poradnik-dla-dziecka")

getPlusyMinusyR :: Handler Html
getPlusyMinusyR = do
  contentLayout "poradnik" $ do
    setTitle "Plusy i minusy - Poradnik użytkownika - Uszata strona"
    $(widgetFile "poradnik-plusy-minusy")

getPodstawoweR :: Handler Html
getPodstawoweR = do
  contentLayout "poradnik" $ do
    setTitle "Podstawowe informacje - Poradnik użytkownika - Uszata strona"
    $(widgetFile "poradnik-podstawowe-info")
