EasyLocalNumber
===============

### About EasyLocalNumber
EasyLocalNumber is a behavior script that can be applied to a LiveCode text field, to make it easier for you to work with formatted, localised numbers in your stacks. By 'formatted' and 'localised' numbers' we mean numbers that have custom decimal and thousands separators, and numbers that can include local currency symbols.

## Quickstart

  1. Copy the contents of the script "easylocalnumber.lc", and paste it into a new button in your stack. 

  2. Set the 'behavior' property of a field you want to turn into an EasyLocalNumber field to the long id of the button you just created.

  3. Add the 4 custom properties described below to your field

  4. Set the values of the properties as described, so your field will work as you expect.

__OPTIONAL:__

  * It is also highly recommended that your field should have its "dontWrap" and "autoTab" properties set to 'true'.

  * You can customise the appearance of your field using fonts, text styles and colours, as usual.

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

## Decimal & Thousands Separators

A number can contain a decimal separator, and several thousands separators. 
For instance, in the number...:
```
  98,765,432.10
```
...the comma is a __thousands separator__, and the period (full stop) is the __decimal separator__. This is the kind of number that LiveCode expects in your scripts - and it is actually easier for LiveCode if you leave out the thousands separators altogether.

If you live in a country where you normally use commas and periods as separators like this, then all is fine. Different countries, however, use different characters as separators. In many parts of Latin America, for instance, they do the opposite: they use the comma as a decimal separator, and periods for thousands. And the differences don't stop there: in some countries it is fine for you to leave out the thousands separator, but in others it is not.

When you write your programs, you will usually want to allow users to enter numbers using the default separators for their own country and culture, and you will need to display these numbers using the same local defaults. 

Your EasyLocalNumber field should have two custom properties, __cDecimalSep__ and __cThouSep__. They allow you to specify which characters will be used - respectively - as decimal and thousands separators in the field. Setting these properties means that your  users can type these characters in the field, and also that you want to use these separators when the field displays numbers in that field to your users.

The decimal separator is *mandatory* - that is: the user MUST type it to indicate where the decimal place starts. The thousands separator, however, is *optional*: it is ok for the user not to type one if they forget. If you specified one in the cThouSep property, when your field displays a number that needs it, it will use it.

LiveCode, however, does not understand 'localised' numbers, and depending on the separators being used, may interpret them as strings or lists. That means, that after a user enters their localised number in your field, if you want to use that localised number in your scripts you will have to convert it to the 'standard' LiveCode number format. EasyLocalNumber automates this process for you, too.

Despite of how the number is being displayed to the user, you can access the 'standard' numeric value of the field by using a virtual custom property called __cNum__. It is called a _virtual_ property, because it is a property that is automatically calculated at runtime - you never need to add it to the field. You get the numerical value of the field, therefore, just by getting its cNum property, like this:
```
get the cNum of field "subTotal"
multiply it by 1.1
```
If after using the value in your scripts you need to display it back in the field, just set the cNum property to a new value. The field will automatically update itself to display the new value using the localised separators.
```
set the cNum of field "taxIncTotal" to it
```
In short, this means that your user can enter a number in your EasyLocalNumber field using the separators they are used to, and the number will always be displayed to them using their own, local formatting. When you want to get or set the value of the field in your scripts, just use the cNum virtual property.
