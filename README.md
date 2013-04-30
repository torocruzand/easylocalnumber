EasyLocalNumber
===============

### About EasyLocalNumber
EasyLocalNumber is a behavior script that can be applied to a LiveCode text field, to make it easier for you to work with formatted, localised numbers in your stacks. By 'formatted' and 'localised' numbers' we mean numbers that have custom decimal and thousands separators, and numbers that can include local currency symbols.

### Quickstart

  1) Copy the contents of the script "easylocalnumber.lc", and paste it into a new button in your stack. 

  2) Set the 'behavior' property of a field you want to turn into an EasyLocalNumber field to the long id of the button you just created.

  3) Add the 4 custom properties described below to your field

  4) Set the values of the properties as described, so your field will work as you expect.

__OPTIONAL:__
  5) It is also highly recommended that your field should have its "dontWrap" and "autoTab" properties set to 'true'.

  6) You can customise the appearance of your field using fonts, text styles and colours, as usual.

__ACCESSING THE NUMERICAL VALUE IN THE FIELD__
To access (get and set) the numerical value in the field from your scripts, use the 'cNum' virtual property:
  ```
          get the cNum of field "currencyTotal"
            multiply it by 1.1
          set the cNum of field "currencyTotal" to it
  ```

__CUSTOM PROPERTIES__
You should add the following custom properties to your EasyLocalNum field:

   * __cDecimalSep__ - a character that works as a DECIMAL SEPARATOR in the user's locale
   * __cThouSep__ - a character that works as a THOUSANDS SEPARATOR in the user's locale
   * __cSymbol__ - the CURRENCY SYMBOL for the user's locale - ie, "€", "AU$", etc.
   * __cSymbolPos__ - "before" or "after": the position of the symbol relative to the number

For further details, read through the "Separators", "Currency" and "Examples" sections.
