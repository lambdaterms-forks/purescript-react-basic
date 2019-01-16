module React.Basic.EventProcessor where

import Prelude

import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Data.These (These, maybeThese)
import Effect (Effect)
import Effect.Uncurried (mkEffectFn1)
import React.Basic.Events (EventHandler, handler_) as Events
import React.Basic.Events (SyntheticEvent)
import Unsafe.Coerce (unsafeCoerce)
import Web.HTML (HTMLElement)

-- | XXX: we want to migrate to this API finally
-- |      and drop original EventFn
foreign import data ScopedSyntheticEvent ∷ Type → Type

fromReactBasicSyntheticEvent ∷ ∀ h. SyntheticEvent → ScopedSyntheticEvent h
fromReactBasicSyntheticEvent = unsafeCoerce

toReactBasicSyntheticEvent ∷ ∀ h. ScopedSyntheticEvent h → SyntheticEvent
toReactBasicSyntheticEvent = unsafeCoerce

type EventProcessor h a = ScopedSyntheticEvent h → Effect a

type ResultHandler a = a → Effect Unit

type Handle h a =
  { eventProcessor ∷ EventProcessor h a
  , resultHandler ∷ ResultHandler a
  }

handle ∷ ∀ a.
  (∀ h. Handle h a) → Events.EventHandler
handle { eventProcessor, resultHandler } = handle' eventProcessor resultHandler

handle' ∷ ∀ a. (∀ h. EventProcessor h a) → ResultHandler a → Events.EventHandler
handle' eventProcessor resultHandler =
  mkEffectFn1 (fromReactBasicSyntheticEvent >>> pure >=> eventProcessor >=> resultHandler)

handle_ ∷ Effect Unit → Events.EventHandler
handle_ = Events.handler_

type ReactEventAttrs =
  { altKey ∷ Nullable Boolean
  , button ∷ Nullable Int
  , buttons ∷ Nullable Int
  , clientX ∷ Nullable Number
  , clientY ∷ Nullable Number
  , ctrlKey ∷ Nullable Boolean
  , currentTarget ∷ Nullable HTMLElement
  , currentTargetX ∷ Nullable Number
  , currentTargetY ∷ Nullable Number
  , isDefaultPrevented ∷ Effect Boolean
  , isTrusted ∷ Nullable Boolean
  , metaKey ∷ Nullable Boolean
  , preventDefault ∷ Effect Unit
  , shiftKey ∷ Nullable Boolean
  , stopPropagation ∷ Effect Unit
  , target ∷ { element ∷ HTMLElement, value ∷ Nullable String }
  }

toReactEventAttrs ∷ ∀ h. ScopedSyntheticEvent h → ReactEventAttrs
toReactEventAttrs = unsafeCoerce

-- | Normalized wheel event field
-- Based on npm's normalize wheel
type NormalizedWheel =
  { spinX :: Number
  , spinY :: Number
  , pixelX :: Number
  , pixelY :: Number }

foreign import normalizedWheelImpl :: ∀ h. ScopedSyntheticEvent h -> Nullable NormalizedWheel

normalizedWheel ∷ ∀ h. EventProcessor h (Maybe NormalizedWheel)
normalizedWheel = normalizedWheelImpl >>> toMaybe >>> pure

foreign import targetXImpl ∷ ∀ h. ScopedSyntheticEvent h → Nullable Number
foreign import targetYImpl ∷ ∀ h. ScopedSyntheticEvent h → Nullable Number

targetX ∷ ∀ h. EventProcessor h (Maybe Number)
targetX = targetXImpl >>> toMaybe >>> pure

targetY ∷ ∀ h. EventProcessor h (Maybe Number)
targetY = targetYImpl >>> toMaybe >>> pure

foreign import currentTargetXImpl ∷ ∀ h. ScopedSyntheticEvent h → Nullable Number

currentTargetX ∷ ∀ h. EventProcessor h (Maybe Number)
currentTargetX = currentTargetXImpl >>> toMaybe >>> pure

foreign import currentTargetYImpl ∷ ∀ h. ScopedSyntheticEvent h → Nullable Number

currentTargetY ∷ ∀ h. EventProcessor h (Maybe Number)
currentTargetY = currentTargetYImpl >>> toMaybe >>> pure

currentTarget ∷ ∀ h. EventProcessor h (Maybe HTMLElement)
currentTarget = toReactEventAttrs >>> _.currentTarget >>> toMaybe >>> pure

altKey ∷ ∀ h. EventProcessor h (Maybe Boolean)
altKey = toReactEventAttrs >>> _.altKey >>> toMaybe >>> pure

button ∷ ∀ h. EventProcessor h (Maybe Int)
button = toReactEventAttrs >>> _.button >>> toMaybe >>> pure

buttons ∷ ∀ h. EventProcessor h (Maybe Int)
buttons = toReactEventAttrs >>> _.buttons >>> toMaybe >>> pure

clientX ∷ ∀ h. EventProcessor h (Maybe Number)
clientX = toReactEventAttrs >>> _.clientX >>> toMaybe >>> pure

clientY ∷ ∀ h. EventProcessor h (Maybe Number)
clientY = toReactEventAttrs >>> _.clientY >>> toMaybe >>> pure

ctrlKey ∷ ∀ h. EventProcessor h (Maybe Boolean)
ctrlKey = toReactEventAttrs >>> _.ctrlKey >>> toMaybe >>> pure

isDefaultPrevented ∷ ∀ h. EventProcessor h Boolean
isDefaultPrevented e = do
  p ← (toReactEventAttrs e).isDefaultPrevented
  pure p

isTrusted ∷ ∀ h. EventProcessor h (Maybe Boolean)
isTrusted = toReactEventAttrs >>> _.isTrusted >>> toMaybe >>> pure

metaKey ∷ ∀ h. EventProcessor h (Maybe Boolean)
metaKey = toReactEventAttrs >>> _.metaKey >>> toMaybe >>> pure

preventDefault ∷ ∀ h. EventProcessor h Unit
preventDefault e = do
  _ ← (unsafeCoerce e).preventDefault
  pure unit

shiftKey ∷ ∀ h. EventProcessor h (Maybe Boolean)
shiftKey = toReactEventAttrs >>> _.shiftKey >>> toMaybe >>> pure

stopPropagation ∷ ∀ h. EventProcessor h Unit
stopPropagation e = (unsafeCoerce e).stopPropagation

targetValue :: ∀ h. EventProcessor h (Maybe String)
targetValue =
  (toReactEventAttrs >>> pure >=> _.target >>> pure >=> _.value >>> toMaybe) >>> pure

-- Quite custom touch hadling - only first touch is treated as single touch
-- so if you have both touches and remove first one it won't count.
type Touch =
  { clientX ∷ Number
  , clientY ∷ Number
  , pageX ∷ Number
  , pageY ∷ Number
  , targetX ∷ Number
  , targetY ∷ Number
  }

type Touches =
  { first ∷ Touch
  , second ∷ Maybe Touch
  }

type TouchesImpl =
  { first ∷ Touch
  , second ∷ Nullable Touch
  }

foreign import touchesImpl ∷ ∀ h. ScopedSyntheticEvent h → Nullable TouchesImpl

touches ∷ ∀ h. EventProcessor h (Maybe Touches)
touches = touchesImpl >>> toMaybe >>> map toTouches >>> pure
  where
    toTouches tImpl =
      { first: tImpl.first
      , second: toMaybe tImpl.second
      }

type ChangedTouchesImpl =
  { first ∷ Nullable Touch
  , second ∷ Nullable Touch
  }

type ChangedTouches = These Touch Touch

foreign import changedTouchesImpl ∷ ∀ h. ScopedSyntheticEvent h → ChangedTouchesImpl

changedTouches ∷ ∀ h. EventProcessor h (Maybe ChangedTouches)
changedTouches = changedTouchesImpl >>> toTouches >>> pure
  where
    toTouches { first, second } = maybeThese (toMaybe first) (toMaybe second)

