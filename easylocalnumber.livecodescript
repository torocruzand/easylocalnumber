/*
@TODO implement a customisable number of decimal places in the local number.
*/
before textChanged
   -- if the field is empty then we don't need to do anything:
   if me is empty then pass textChanged

   -- for speed:
   local tLockStatus
   put the lockMessages into tLockStatus
   lock messages

   -- saving the current position of the text cursor:
   local tTxtCursorPos
   put word 4 of the selectedChunk into tTxtCursorPos

   -- catching the situation where the user is next to a decimal separator,
   -- and types it again - it should just 'skip' past the separator, rather than
   -- type a second one in the field:
   if (char tTxtCursorPos of me is the cDecimalSep of me) and \
         (char tTxtCursorPos+1 of me is the cDecimalSep of me) then
      delete char tTxtCursorPos+1 of me
      pass textChanged
   end if

   -- change field contents to a LiveCode number,
   -- keeping track of the text cursor position:
   local tEditedNum
   put localNumToNum(me,tTxtCursorPos) into tEditedNum

   -- change back to a localised number,
   -- keeping track of the text cursor position:
   put numToLocalNum(tEditedNum["number"], tEditedNum["cursor"]) into tEditedNum

   -- resetting the text and the cursor position:
   put tEditedNum["number"] into me
   put tEditedNum["cursor"] into tTxtCursorPos
   select char (tTxtCursorPos)+1 to tTxtCursorPos of me

   -- to finish off, unlock messages, if needed:
   if tLockStatus is false then unlock messages
end textChanged


/*
If the field is displaying a currency value, then we need to handle operations
like deleting numbers around the decimal separator, and deleting a minus sign
appearing before a currency symbol.
*/
on backspaceKey
   -- if the user has an actual text selection - rather than just an insertion point -
   -- we assume the action is intentional, and just let it happen:
   if word 2 of the selectedChunk <= word 4 of the selectedChunk then pass backspaceKey
   local tTxtCursorPos
   put word 4 of the selectedChunk into tTxtCursorPos

   -- if the previous character is a decimal separator, we just 'skip' it:
   if char tTxtCursorPos of me is the cDecimalSep of me then
      select char tTxtCursorPos to tTxtCursorPos-1 of me
      exit backspaceKey
   end if

   -- if we are to the left of a minus sign and the currency symbol,
   -- then we delete the minus sign:
   if char 1 to (the length of the cSymbol of me + 1) of me is ("-" & the cSymbol of me) and \
         (tTxtCursorPos is (the length of the cSymbol of me + 1)) then
      delete first char of me
      select char tTxtCursorPos to tTxtCursorPos-1 of me
      send "textChanged" to me
      exit backspaceKey
   end if

   pass backspaceKey
end backspaceKey


on deleteKey
   -- if the user has an actual text selection - rather than just an insertion point -
   -- we assume the action is intentional, and just let it happen:
   if word 2 of the selectedChunk <= word 4 of the selectedChunk then pass deleteKey
   local tTxtCursorPos
   put word 2 of the selectedChunk into tTxtCursorPos

   -- if the previous character is a decimal separator, we just 'skip' it:
   if char tTxtCursorPos of me is the cDecimalSep of me then
      select char tTxtCursorPos+1 to tTxtCursorPos of me
      exit deleteKey
   else
      pass deleteKey
   end if
end deleteKey



/*
=============================================
GETTERS & SETTERS
=============================================
*/

/*
We store the number idirectly n the field, in its localised format.

@param pNum number a LiveCode integer or decimal (floating-point) number.
*/
setProp cNum pNum
   if pNum is not a number then exit cNum
   put numToLocalNum(pNum) into pNum
   put pNum["number"] into me
end cNum

/*
We derive the number directly from the field, in its localised format.
*/
getProp cNum
   local tNum
   put localNumToNum(me) into tNum
   return tNum["number"]
end cNum

/*
The decimal separator is *required* to exist. If no decimal separator is set, it will default to
LiveCode's standard "." - the full-stop, or period. Consequently, it is not possible to set the
decimal separator to 'empty'.

The decimal separator is always 1 single character - in every culture. If more than one character
is passed, then only the first character of the string will be used.

Lastly, the decimal separator and the thousands separator should be different from each other.
Trying to set a decimal separator equal to the thousands separator will cause the thousands
separator to set to 'empty'.
*/
setProp cDecimalSep pString
   if pString is empty then exit cDecimalSep
   if the length of pString > 1 then put char 1 of pString into pString
   if pString is the cThouSep of me then set the cThouSep of me to empty
   replace the cDecimalSep of me with pString in me
   pass cDecimalSep
end cDecimalSep

getProp cDecimalSep
   if the cDecimalSep of me is empty then
      return "."
   else
      return the cDecimalSep of me
   end if
end cDecimalSep


/*
When we change the thousands separator, we should auto-replace any existing
thousands separators, if required.

The thousands separator is always 1 single character - in every culture. If more than one character
is passed, then only the first character of the string will be used.

The thousands separator has to be different from the decimal separator.
*/
setProp cThouSep pString
   -- we cannot allow the thousands separator to be made the same as the decimal separator:
   if the length of pString > 1 then put char 1 of pString into pString
   if (pString is not empty) and (pString is the cDecimalSep of me) then exit cThouSep
   if (the cThouSep of me is not empty) then
      replace the cThouSep of me with pString in me
      pass cThouSep
   else
      -- if cThouSep was empty, then we must add thousand separators to the number:
      local tNum
      put localNumToNum(me) into tNum
      set the cThouSep of me to pString
      put numToLocalNum(tNum["number"]) into tNum
      put tNum["number"] into me
   end if
end cThouSep

/*
When we change the currency symbol, we should auto-replace any existing
currency sumbol, if required.
*/
setProp cSymbol pString
   if (the cSymbol of me is not empty) then
      replace the cSymbol of me with pString in me
      pass cSymbol
   else
      -- if cSymbol was empty, then we must add a currency symbol to the number:
      local tNum
      put localNumToNum(me) into tNum
      set the cSymbol of me to pString
      put numToLocalNum(tNum["number"]) into tNum
      put tNum["number"] into me
   end if
end cSymbol

/*
When we change the currency symbol position, we should auto-fix the position of the symbol
in the field, if required.
*/
setProp cSymbolPos pString
   if (the cSymbolPos of me is pString) then exit cSymbolPos
   -- force redrawing using the new currency symbol position:
   local tNum
   put localNumToNum(me) into tNum
   set the cSymbolPos of me to pString
   put numToLocalNum(tNum["number"]) into tNum
   put tNum["number"] into me
end cSymbolPos


/*
=============================================
INTERNAL PRIVATE FUNCTIONS
=============================================
These functions are used by the 'textChanged' and the accessor handlers above.
It is unlikely they would be of any use outside this context, so they are declared private.
*/


/*
This function gets a string that represents a localised numeric or currency value, and returns
a LiveCode standard number. It is expected that the localised number will be using the
localisation settings stored in the cDecimalSep, cThouSep, cSymbol, and cSymbolPos custom
properties of the field.

Optionally, a text cursor position may be passed to the function. When the number is converted,
the text cursor position will be maintained, relative to the DECIMAL SEPARATOR in the original
localised number - that is: if the cursor was 2 characters to the left of the decimal separator in
the localised number, then the number returned will be 2 characters to the left of the decimal point
in the LiveCode number. If no cursor position is passed, it will returne the position at the end of
the number.

@param pLocalNum string a localised numeric or currency value, using the localisation values set
in the cDecimalSep, cThouSep, cSymbol and cSymbolPos of the field.
@param pTxtCursorPos integer a number indicating the position the cursor is in the localised number.
The first position in the string is "0" - ie, indicating that the cursor should be before char 1.
@return array The returned array will contain 2 keys:
- 'number': will contain the string with the localised number
- 'cursor': will contain an integer indicating the position of the text cursor in the localised number. The
first position in the string is "0" - ie, indicating that the cursor should be before char 1.
*/
function localNumToNum pLocalNum,pTxtCursorPos
   local tResult
   -- check that we have something to work with:
   if pLocalNum is empty then
      put empty into tResult["number"]
      put 0 into tResult["cursor"]
      return tResult
   end if
   if (pTxtCursorPos is not empty) and (pTxtCursorPos is not an integer) then put empty into pTxtCursorPos
   -- the only characters that matter are digits, minus sign and decimal separator,
   -- so we can remove everything else - and update the text cursor position, if needed:
   local tOKChars
   put "-0123456789" into tOKChars
   put the cDecimalSep of me after tOKChars
   repeat with x = the length of pLocalNum down to 1
      if char x of pLocalNum is not in tOKChars then
         delete char x of pLocalNum
         if (pTxtCursorPos is not empty) and (x <= pTxtCursorPos) then subtract 1 from pTxtCursorPos
      end if
   end repeat
   -- replace all localised decimal separators with the LiveCode 'default':
   if the cDecimalSep of me is not empty then replace the cDecimalSep of me with "." in pLocalNum
   -- we may have ended up with more than 1 decimal point - ie., if the user
   -- accidentally typed a second one - so we only keep ONE (the last) one entered:
   local tDecimalFlag
   put false into tDecimalFlag
   repeat with x = the length of pLocalNum down to 1
      if char x of pLocalNum is "." then
         if tDecimalFlag then
            delete char x of pLocalNum
            if (pTxtCursorPos is not empty) and (x <= pTxtCursorPos) then
               subtract 1 from pTxtCursorPos
            end if
         else
            put true into tDecimalFlag
         end if
      end if
   end repeat
   -- removing any unnecessary '0s to the left':
   local tHasMinus
   if first char of pLocalNum is "-" then
      delete first char of pLocalNum
      if (pTxtCursorPos is not empty) and (pTxtCursorPos > 0) then subtract 1 from pTxtCursorPos
      put true into tHasMinus
   else
      put false into tHasMinus
   end if
   repeat while the first char of pLocalNum is "0"
      delete first char of pLocalNum
      if (pTxtCursorPos is not empty) and (pTxtCursorPos > 0) then subtract 1 from pTxtCursorPos
   end repeat
   if tHasMinus then
      put "-" before pLocalNum
      add 1 to pTxtCursorPos
   end if
   -- finally:
   if pTxtCursorPos is empty then put the length of pLocalNum into pTxtCursorPos
   put pLocalNum into tResult["number"]
   put pTxtCursorPos into tResult["cursor"]
   return tResult
end localNumToNum


/*
This function gets a LiveCode number, and returns a localised numeric or currency value,
using the localisation settings stored in the cDecimalSep, cThouSep, cSymbol, and cSymbolPos
custom properties of the field.

Optionally, a text cursor position may be passed to the function. When the number is converted,
the text cursor position will be maintained, relative to the DECIMAL SEPARATOR in the original
LiveCode number - that is: if the cursor was 2 characters to the left of the decimal separator in
the LiveCode number, then the number returned will be 2 characters to the left of the decimal point
in the localised number. If no cursor position is passed, it will returne the position at the end of
the number.

@param pNum number a LiveCode number.
@param pTxtCursorPos integer a number indicating the position the cursor is in the LiveCode number.
The first position in the string is "0" - ie, indicating that the cursor should be before char 1.
@return array The returned array will contain 2 keys:
- 'number': will contain the string with the localised numeric or currency value, using the localisation values
set in the cDecimalSep, cThouSep, cSymbol and cSymbolPos of the field.
- 'cursor': will contain an integer indicating the position of the text cursor in the localised number.
*/
function numToLocalNum pNum,pTxtCursorPos
   -- check that we have something to work with:
   local tResult
   if pNum is empty then
      put empty into tResult["number"]
      put 0 into tResult["cursor"]
      return tResult
   end if
   -- flags which will determine what kind of number we are formatting:
   local tHasMinus, tHasDecimalSep, tHasDigits, tIsCurrency
   if first char of pNum is "-" then -- setting tHasMinus
      delete first char of pNum
      if (pTxtCursorPos is not empty) and (pTxtCursorPos > 0) then subtract 1 from pTxtCursorPos
      put true into tHasMinus
   else
      put false into tHasMinus
   end if
   if "." is in pNum then -- setting tHasDecimalSep
      put true into tHasDecimalSep
   else
      put false into tHasDecimalSep
   end if
   -- split the 'integer' and 'decimal' parts of the number:
   local tInt, tDec
   set the itemDelimiter to "."
   put item 1 of pNum into tInt
   put item 2 of pNum into tDec
   set the itemDelimiter to comma
   -- if the user simply typed the decimal separator without an integer part,
   -- we'll add a '0' to the left of the decimal point, as courtesy:
   if tHasDecimalSep and (tInt is empty) then
      put 0 into tInt
      if pTxtCursorPos > 0 then add 1 to pTxtCursorPos
   end if
   -- if the number is currency, then we'll round it off to 2 decimal digits:
   put false into tHasDigits -- setting tHasDigits
   put tInt & tDec into pNum -- aggregate all chars in the integer and fractional parts
   repeat for each char x in pNum
      if x is a number then
         put true into tHasDigits
         exit repeat
      end if
   end repeat
   if tHasDigits and (the cSymbol of me is not empty) and \
         ((the cSymbolPos of me is "after") or (the cSymbolPos of me is "before")) then -- setting tIsCurrency
      put true into tIsCurrency
   else
      put false into tIsCurrency
   end if
   if tIsCurrency and the length of tDec > 2 then
      put "0." before tDec
      put round(tDec,2) into tDec
      delete char 1 to 2 of tDec
      if (pTxtCursorPos is not empty) and (pTxtCursorPos > (the length of tInt + 3)) then
         put (the length of tInt + 3) into pTxtCursorPos
      end if
   end if
   if tIsCurrency and the length of tDec < 2 then
      repeat while (the length of tDec < 2)
         put "0" after tDec
      end repeat
   end if
   -- now we start re-assembling the number, in localised format, back into pNum.
   -- first, add the thousands separators to the integer part, if required:
   put last char of tInt into pNum
   repeat with x = -2 down to (the length of tInt * -1)
      if abs(x) mod 3 is 1 then
         put the cThouSep of me before pNum
         if (pTxtCursorPos is not empty) and ((the length of tInt+x) < pTxtCursorPos) then add 1 to pTxtCursorPos
      end if
      put char x of tInt before pNum
   end repeat
   -- add the decimal separator and decimal part of the number, if needed:
   if tHasDecimalSep or tIsCurrency then put the cDecimalSep of me & tDec after pNum
   -- add the currency symbol, if needed:
   if tIsCurrency and the cSymbolPos of me is "after" then put the cSymbol of me after pNum
   if tIsCurrency and the cSymbolPos of me is "before" then
      put the cSymbol of me before pNum
      if (pTxtCursorPos is not empty) then add the length of the cSymbol of me to pTxtCursorPos
   end if
   -- add the minus sign, if needed:
   if tHasMinus then
      put "-" before pNum
      if (pTxtCursorPos is not empty) then add 1 to pTxtCursorPos
   end if
   -- finally:
   if pTxtCursorPos is empty then
      put the length of pNum into tResult["cursor"]
   else
      put pTxtCursorPos into tResult["cursor"]
   end if
   put pNum into tResult["number"]
   return tResult
end numToLocalNum
