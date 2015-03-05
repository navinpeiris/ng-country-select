describe 'ng-country-select', ->
  beforeEach ->
    jasmine.addMatchers
      toBeEmpty: ->
        compare: (actual) ->
          pass: actual.length == 0
          message: "Expected #{actual} to be empty"
        negativeCompare: (actual) ->
          pass: actual.length != 0
          message: "Expected #{actual} not to be empty"

  describe 'directive', ->
    scope = null
    compile = null
    element = null

    beforeEach module 'countrySelect'
    beforeEach inject ($rootScope, $compile) ->
      scope = $rootScope.$new()
      compile = $compile

    compileElement = (elementSource) ->
      element = compile(elementSource)(scope);
      scope.$digest()

    numTotalOptions = 251

    options = -> element.find('option')
    firstOption = -> element.find('option')[0]
    optionAtIndex = (index) -> $(options()[index])
    optionWithValue = (value) -> $(element[0]).find('option[value="' + value + '"]')[0]

    separatorValue = '---------------'
    separator = -> optionWithValue(separatorValue)


    it 'replaces attribute with a select element', ->
      compileElement '<country-select></country-select>'

      expect(element[0].nodeName).toEqual 'SELECT'

    it 'contains a list of options', ->
      compileElement '<country-select></country-select>'

      expect(element.find('option')).not.toBeEmpty()

    it 'does not replace id, class etc attribute set on the element', ->
      compileElement '<country-select id="foo" class="wam bam" name="bar"></country-select>'

      expect(element.attr('id')).toEqual 'foo'

      expect(element.attr('name')).toEqual 'bar'

      expect(element.hasClass('wam')).toBe true
      expect(element.hasClass('bam')).toBe true

    describe 'with required option', ->
      emptyOption = -> optionWithValue('')

      describe 'when not specified', ->
        beforeEach -> compileElement '<country-select></country-select>'

        it 'contains an empty option as the first option', ->
          expect(emptyOption()).not.toBeUndefined()

          expect($(firstOption()).val()).toEqual ''
          expect($(firstOption()).text()).toEqual ''

      describe 'when specified', ->
        beforeEach -> compileElement '<country-select required></country-select>'

        it 'does not contain an empty option', ->
          expect(emptyOption()).toBeUndefined()

    describe 'with selected option', ->
      selectedOptions = -> $(element[0]).find('option:selected')

      describe 'when not specified', ->
        beforeEach -> compileElement '<country-select></country-select>'

        it 'has one option marked as selected', ->
          expect(selectedOptions().length).toEqual 1

        it 'has the first option marked as selected', ->
          expect(selectedOptions()[0].textContent).toEqual ''

      describe 'when specified', ->
        beforeEach -> compileElement '<country-select cs-selected="UZ"></country-select>'

        it 'has one option marked as selected', ->
          expect(selectedOptions().length).toEqual 1

        it 'has the specified option marked as selected', ->
          expect($(selectedOptions()[0]).text()).toEqual 'Uzbekistan'

    describe 'with priorities option', ->
      describe 'when not specified', ->
        beforeEach -> compileElement '<country-select></country-select>'

        it 'returns options in the default order', ->
          expect($(firstOption()).val()).toEqual ''

        it 'does not include a separator', ->
          expect(separator()).toBeUndefined()

      describe 'when specified as empty string', ->
        beforeEach -> compileElement '<country-select cs-priorities=""></country-select>'

        it 'returns options in the default order', ->
          expect($(firstOption()).val()).toEqual ''

        it 'does not include a separator', ->
          expect(separator()).toBeUndefined()

      describe 'when specified with country codes', ->
        beforeEach -> compileElement '<country-select cs-priorities="AU, US, Blah"></country-select>'

        it 'returns options with the priorities first', ->
          expect(optionAtIndex(0).val()).toEqual ''
          expect(optionAtIndex(1).val()).toEqual 'AU'
          expect(optionAtIndex(2).val()).toEqual 'US'

        it 'include a separator after priorities', ->
          expect(optionAtIndex(3).val()).toEqual separatorValue

        it 'separator is disabled', ->
          expect($(separator()).attr('disabled')).toEqual 'disabled'

    describe 'with only option', ->
      describe 'when specified as empty string', ->
        beforeEach -> compileElement '<country-select cs-only=""></country-select>'

        it 'returns options for all countries', ->
          expect(options().length).toEqual numTotalOptions

      describe 'when specified with country codes', ->
        beforeEach -> compileElement '<country-select cs-only=" AU, US , Blah"></country-select>'

        it 'returns options only for the listed countries', ->
          expect(options().length).toEqual 3

          expect(optionAtIndex(0).val()).toEqual ''
          expect(optionAtIndex(1).val()).toEqual 'AU'
          expect(optionAtIndex(2).val()).toEqual 'US'

    describe 'with except option', ->
      describe 'when specified as empty string', ->
        beforeEach -> compileElement '<country-select cs-except=""></country-select>'

        it 'returns options for all countries', ->
          expect(options().length).toEqual numTotalOptions

      describe 'when specified with country codes', ->
        beforeEach -> compileElement '<country-select cs-except=" AU, US , Blah"></country-select>'

        it 'returns options only for the listed countries', ->
          expect(options().length).toEqual (numTotalOptions - 2)

          expect(optionWithValue('AU')).not.toBeDefined()
          expect(optionWithValue('US')).not.toBeDefined()

