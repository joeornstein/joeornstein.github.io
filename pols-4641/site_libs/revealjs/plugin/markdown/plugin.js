/*!
 * The reveal.js markdown plugin. Handles parsing of
 * markdown inside of presentations as well as loading
 * of external markdown documents.
 */

import { marked } from 'marked';

const DEFAULT_SLIDE_SEPARATOR = '\r?\n---\r?\n',
<<<<<<< HEAD
	  DEFAULT_NOTES_SEPARATOR = 'notes?:',
=======
	  DEFAULT_VERTICAL_SEPARATOR = null,
	  DEFAULT_NOTES_SEPARATOR = '^\s*notes?:',
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
	  DEFAULT_ELEMENT_ATTRIBUTES_SEPARATOR = '\\\.element\\\s*?(.+?)$',
	  DEFAULT_SLIDE_ATTRIBUTES_SEPARATOR = '\\\.slide:\\\s*?(\\\S.+?)$';

const SCRIPT_END_PLACEHOLDER = '__SCRIPT_END__';

<<<<<<< HEAD
const CODE_LINE_NUMBER_REGEX = /\[([\s\d,|-]*)\]/;
=======
// match an optional line number offset and highlight line numbers
// [<line numbers>] or [<offset>: <line numbers>]
const CODE_LINE_NUMBER_REGEX = /\[\s*((\d*):)?\s*([\s\d,|-]*)\]/;
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c

const HTML_ESCAPE_MAP = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#39;'
};

const Plugin = () => {

	// The reveal.js instance this plugin is attached to
	let deck;

	/**
	 * Retrieves the markdown contents of a slide section
	 * element. Normalizes leading tabs/whitespace.
	 */
	function getMarkdownFromSlide( section ) {

		// look for a <script> or <textarea data-template> wrapper
<<<<<<< HEAD
		var template = section.querySelector( '[data-template]' ) || section.querySelector( 'script' );

		// strip leading whitespace so it isn't evaluated as code
		var text = ( template || section ).textContent;
=======
		const template = section.querySelector( '[data-template]' ) || section.querySelector( 'script' );

		// strip leading whitespace so it isn't evaluated as code
		let text = ( template || section ).textContent;
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c

		// restore script end tags
		text = text.replace( new RegExp( SCRIPT_END_PLACEHOLDER, 'g' ), '</script>' );

<<<<<<< HEAD
		var leadingWs = text.match( /^\n?(\s*)/ )[1].length,
			leadingTabs = text.match( /^\n?(\t*)/ )[1].length;

		if( leadingTabs > 0 ) {
			text = text.replace( new RegExp('\\n?\\t{' + leadingTabs + '}','g'), '\n' );
		}
		else if( leadingWs > 1 ) {
			text = text.replace( new RegExp('\\n? {' + leadingWs + '}', 'g'), '\n' );
=======
		const leadingWs = text.match( /^\n?(\s*)/ )[1].length,
			leadingTabs = text.match( /^\n?(\t*)/ )[1].length;

		if( leadingTabs > 0 ) {
			text = text.replace( new RegExp('\\n?\\t{' + leadingTabs + '}(.*)','g'), function(m, p1) { return '\n' + p1 ; } );
		}
		else if( leadingWs > 1 ) {
			text = text.replace( new RegExp('\\n? {' + leadingWs + '}(.*)', 'g'), function(m, p1) { return '\n' + p1 ; } );
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
		}

		return text;

	}

	/**
	 * Given a markdown slide section element, this will
	 * return all arguments that aren't related to markdown
	 * parsing. Used to forward any other user-defined arguments
	 * to the output markdown slide.
	 */
	function getForwardedAttributes( section ) {

<<<<<<< HEAD
		var attributes = section.attributes;
		var result = [];

		for( var i = 0, len = attributes.length; i < len; i++ ) {
			var name = attributes[i].name,
=======
		const attributes = section.attributes;
		const result = [];

		for( let i = 0, len = attributes.length; i < len; i++ ) {
			const name = attributes[i].name,
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
				value = attributes[i].value;

			// disregard attributes that are used for markdown loading/parsing
			if( /data\-(markdown|separator|vertical|notes)/gi.test( name ) ) continue;

			if( value ) {
				result.push( name + '="' + value + '"' );
			}
			else {
				result.push( name );
			}
		}

		return result.join( ' ' );

	}

	/**
	 * Inspects the given options and fills out default
	 * values for what's not defined.
	 */
	function getSlidifyOptions( options ) {
<<<<<<< HEAD

		options = options || {};
		options.separator = options.separator || DEFAULT_SLIDE_SEPARATOR;
		options.notesSeparator = options.notesSeparator || DEFAULT_NOTES_SEPARATOR;
=======
		const markdownConfig = deck?.getConfig?.().markdown;

		options = options || {};
		options.separator = options.separator || markdownConfig?.separator || DEFAULT_SLIDE_SEPARATOR;
		options.verticalSeparator = options.verticalSeparator || markdownConfig?.verticalSeparator || DEFAULT_VERTICAL_SEPARATOR;
		options.notesSeparator = options.notesSeparator || markdownConfig?.notesSeparator || DEFAULT_NOTES_SEPARATOR;
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
		options.attributes = options.attributes || '';

		return options;

	}

	/**
	 * Helper function for constructing a markdown slide.
	 */
	function createMarkdownSlide( content, options ) {

		options = getSlidifyOptions( options );

<<<<<<< HEAD
		var notesMatch = content.split( new RegExp( options.notesSeparator, 'mgi' ) );
=======
		const notesMatch = content.split( new RegExp( options.notesSeparator, 'mgi' ) );
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c

		if( notesMatch.length === 2 ) {
			content = notesMatch[0] + '<aside class="notes">' + marked(notesMatch[1].trim()) + '</aside>';
		}

		// prevent script end tags in the content from interfering
		// with parsing
		content = content.replace( /<\/script>/g, SCRIPT_END_PLACEHOLDER );

		return '<script type="text/template">' + content + '</script>';

	}

	/**
	 * Parses a data string into multiple slides based
	 * on the passed in separator arguments.
	 */
	function slidify( markdown, options ) {

		options = getSlidifyOptions( options );

<<<<<<< HEAD
		var separatorRegex = new RegExp( options.separator + ( options.verticalSeparator ? '|' + options.verticalSeparator : '' ), 'mg' ),
			horizontalSeparatorRegex = new RegExp( options.separator );

		var matches,
=======
		const separatorRegex = new RegExp( options.separator + ( options.verticalSeparator ? '|' + options.verticalSeparator : '' ), 'mg' ),
			horizontalSeparatorRegex = new RegExp( options.separator );

		let matches,
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
			lastIndex = 0,
			isHorizontal,
			wasHorizontal = true,
			content,
			sectionStack = [];

		// iterate until all blocks between separators are stacked up
		while( matches = separatorRegex.exec( markdown ) ) {
<<<<<<< HEAD
			var notes = null;
=======
			const notes = null;
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c

			// determine direction (horizontal by default)
			isHorizontal = horizontalSeparatorRegex.test( matches[0] );

			if( !isHorizontal && wasHorizontal ) {
				// create vertical stack
				sectionStack.push( [] );
			}

			// pluck slide content from markdown input
			content = markdown.substring( lastIndex, matches.index );

			if( isHorizontal && wasHorizontal ) {
				// add to horizontal stack
				sectionStack.push( content );
			}
			else {
				// add to vertical stack
				sectionStack[sectionStack.length-1].push( content );
			}

			lastIndex = separatorRegex.lastIndex;
			wasHorizontal = isHorizontal;
		}

		// add the remaining slide
		( wasHorizontal ? sectionStack : sectionStack[sectionStack.length-1] ).push( markdown.substring( lastIndex ) );

<<<<<<< HEAD
		var markdownSections = '';

		// flatten the hierarchical stack, and insert <section data-markdown> tags
		for( var i = 0, len = sectionStack.length; i < len; i++ ) {
=======
		let markdownSections = '';

		// flatten the hierarchical stack, and insert <section data-markdown> tags
		for( let i = 0, len = sectionStack.length; i < len; i++ ) {
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
			// vertical
			if( sectionStack[i] instanceof Array ) {
				markdownSections += '<section '+ options.attributes +'>';

				sectionStack[i].forEach( function( child ) {
					markdownSections += '<section data-markdown>' + createMarkdownSlide( child, options ) + '</section>';
				} );

				markdownSections += '</section>';
			}
			else {
				markdownSections += '<section '+ options.attributes +' data-markdown>' + createMarkdownSlide( sectionStack[i], options ) + '</section>';
			}
		}

		return markdownSections;

	}

	/**
	 * Parses any current data-markdown slides, splits
	 * multi-slide markdown into separate sections and
	 * handles loading of external markdown.
	 */
	function processSlides( scope ) {

		return new Promise( function( resolve ) {

<<<<<<< HEAD
			var externalPromises = [];
=======
			const externalPromises = [];
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c

			[].slice.call( scope.querySelectorAll( 'section[data-markdown]:not([data-markdown-parsed])') ).forEach( function( section, i ) {

				if( section.getAttribute( 'data-markdown' ).length ) {

					externalPromises.push( loadExternalMarkdown( section ).then(

						// Finished loading external file
						function( xhr, url ) {
							section.outerHTML = slidify( xhr.responseText, {
								separator: section.getAttribute( 'data-separator' ),
								verticalSeparator: section.getAttribute( 'data-separator-vertical' ),
								notesSeparator: section.getAttribute( 'data-separator-notes' ),
								attributes: getForwardedAttributes( section )
							});
						},

						// Failed to load markdown
						function( xhr, url ) {
							section.outerHTML = '<section data-state="alert">' +
								'ERROR: The attempt to fetch ' + url + ' failed with HTTP status ' + xhr.status + '.' +
								'Check your browser\'s JavaScript console for more details.' +
								'<p>Remember that you need to serve the presentation HTML from a HTTP server.</p>' +
								'</section>';
						}

					) );

				}
				else {

					section.outerHTML = slidify( getMarkdownFromSlide( section ), {
						separator: section.getAttribute( 'data-separator' ),
						verticalSeparator: section.getAttribute( 'data-separator-vertical' ),
						notesSeparator: section.getAttribute( 'data-separator-notes' ),
						attributes: getForwardedAttributes( section )
					});

				}

			});

			Promise.all( externalPromises ).then( resolve );

		} );

	}

	function loadExternalMarkdown( section ) {

		return new Promise( function( resolve, reject ) {

<<<<<<< HEAD
			var xhr = new XMLHttpRequest(),
				url = section.getAttribute( 'data-markdown' );

			var datacharset = section.getAttribute( 'data-charset' );

			// see https://developer.mozilla.org/en-US/docs/Web/API/element.getAttribute#Notes
			if( datacharset != null && datacharset != '' ) {
=======
			const xhr = new XMLHttpRequest(),
				url = section.getAttribute( 'data-markdown' );

			const datacharset = section.getAttribute( 'data-charset' );

			// see https://developer.mozilla.org/en-US/docs/Web/API/element.getAttribute#Notes
			if( datacharset !== null && datacharset !== '' ) {
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
				xhr.overrideMimeType( 'text/html; charset=' + datacharset );
			}

			xhr.onreadystatechange = function( section, xhr ) {
				if( xhr.readyState === 4 ) {
					// file protocol yields status code 0 (useful for local debug, mobile applications etc.)
					if ( ( xhr.status >= 200 && xhr.status < 300 ) || xhr.status === 0 ) {

						resolve( xhr, url );

					}
					else {

						reject( xhr, url );

					}
				}
			}.bind( this, section, xhr );

			xhr.open( 'GET', url, true );

			try {
				xhr.send();
			}
			catch ( e ) {
				console.warn( 'Failed to get the Markdown file ' + url + '. Make sure that the presentation and the file are served by a HTTP server and the file can be found there. ' + e );
				resolve( xhr, url );
			}

		} );

	}

	/**
	 * Check if a node value has the attributes pattern.
	 * If yes, extract it and add that value as one or several attributes
	 * to the target element.
	 *
	 * You need Cache Killer on Chrome to see the effect on any FOM transformation
	 * directly on refresh (F5)
	 * http://stackoverflow.com/questions/5690269/disabling-chrome-cache-for-website-development/7000899#answer-11786277
	 */
	function addAttributeInElement( node, elementTarget, separator ) {

<<<<<<< HEAD
		var mardownClassesInElementsRegex = new RegExp( separator, 'mg' );
		var mardownClassRegex = new RegExp( "([^\"= ]+?)=\"([^\"]+?)\"|(data-[^\"= ]+?)(?=[\" ])", 'mg' );
		var nodeValue = node.nodeValue;
		var matches,
			matchesClass;
		if( matches = mardownClassesInElementsRegex.exec( nodeValue ) ) {

			var classes = matches[1];
			nodeValue = nodeValue.substring( 0, matches.index ) + nodeValue.substring( mardownClassesInElementsRegex.lastIndex );
			node.nodeValue = nodeValue;
			while( matchesClass = mardownClassRegex.exec( classes ) ) {
=======
		const markdownClassesInElementsRegex = new RegExp( separator, 'mg' );
		const markdownClassRegex = new RegExp( "([^\"= ]+?)=\"([^\"]+?)\"|(data-[^\"= ]+?)(?=[\" ])", 'mg' );
		let nodeValue = node.nodeValue;
		let matches,
			matchesClass;
		if( matches = markdownClassesInElementsRegex.exec( nodeValue ) ) {

			const classes = matches[1];
			nodeValue = nodeValue.substring( 0, matches.index ) + nodeValue.substring( markdownClassesInElementsRegex.lastIndex );
			node.nodeValue = nodeValue;
			while( matchesClass = markdownClassRegex.exec( classes ) ) {
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
				if( matchesClass[2] ) {
					elementTarget.setAttribute( matchesClass[1], matchesClass[2] );
				} else {
					elementTarget.setAttribute( matchesClass[3], "" );
				}
			}
			return true;
		}
		return false;
	}

	/**
	 * Add attributes to the parent element of a text node,
	 * or the element of an attribute node.
	 */
	function addAttributes( section, element, previousElement, separatorElementAttributes, separatorSectionAttributes ) {

<<<<<<< HEAD
		if ( element != null && element.childNodes != undefined && element.childNodes.length > 0 ) {
			var previousParentElement = element;
			for( var i = 0; i < element.childNodes.length; i++ ) {
				var childElement = element.childNodes[i];
				if ( i > 0 ) {
					var j = i - 1;
					while ( j >= 0 ) {
						var aPreviousChildElement = element.childNodes[j];
						if ( typeof aPreviousChildElement.setAttribute == 'function' && aPreviousChildElement.tagName != "BR" ) {
=======
		if ( element !== null && element.childNodes !== undefined && element.childNodes.length > 0 ) {
			let previousParentElement = element;
			for( let i = 0; i < element.childNodes.length; i++ ) {
				const childElement = element.childNodes[i];
				if ( i > 0 ) {
					let j = i - 1;
					while ( j >= 0 ) {
						const aPreviousChildElement = element.childNodes[j];
						if ( typeof aPreviousChildElement.setAttribute === 'function' && aPreviousChildElement.tagName !== "BR" ) {
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
							previousParentElement = aPreviousChildElement;
							break;
						}
						j = j - 1;
					}
				}
<<<<<<< HEAD
				var parentSection = section;
				if( childElement.nodeName ==  "section" ) {
					parentSection = childElement ;
					previousParentElement = childElement ;
				}
				if ( typeof childElement.setAttribute == 'function' || childElement.nodeType == Node.COMMENT_NODE ) {
=======
				let parentSection = section;
				if( childElement.nodeName ===  "section" ) {
					parentSection = childElement ;
					previousParentElement = childElement ;
				}
				if ( typeof childElement.setAttribute === 'function' || childElement.nodeType === Node.COMMENT_NODE ) {
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
					addAttributes( parentSection, childElement, previousParentElement, separatorElementAttributes, separatorSectionAttributes );
				}
			}
		}

<<<<<<< HEAD
		if ( element.nodeType == Node.COMMENT_NODE ) {
			if ( addAttributeInElement( element, previousElement, separatorElementAttributes ) == false ) {
=======
		if ( element.nodeType === Node.COMMENT_NODE ) {
			if ( addAttributeInElement( element, previousElement, separatorElementAttributes ) === false ) {
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
				addAttributeInElement( element, section, separatorSectionAttributes );
			}
		}
	}

	/**
	 * Converts any current data-markdown slides in the
	 * DOM to HTML.
	 */
	function convertSlides() {

<<<<<<< HEAD
		var sections = deck.getRevealElement().querySelectorAll( '[data-markdown]:not([data-markdown-parsed])');
=======
		const sections = deck.getRevealElement().querySelectorAll( '[data-markdown]:not([data-markdown-parsed])');
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c

		[].slice.call( sections ).forEach( function( section ) {

			section.setAttribute( 'data-markdown-parsed', true )

<<<<<<< HEAD
			var notes = section.querySelector( 'aside.notes' );
			var markdown = getMarkdownFromSlide( section );
=======
			const notes = section.querySelector( 'aside.notes' );
			const markdown = getMarkdownFromSlide( section );
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c

			section.innerHTML = marked( markdown );
			addAttributes( 	section, section, null, section.getAttribute( 'data-element-attributes' ) ||
							section.parentNode.getAttribute( 'data-element-attributes' ) ||
							DEFAULT_ELEMENT_ATTRIBUTES_SEPARATOR,
							section.getAttribute( 'data-attributes' ) ||
							section.parentNode.getAttribute( 'data-attributes' ) ||
							DEFAULT_SLIDE_ATTRIBUTES_SEPARATOR);

			// If there were notes, we need to re-add them after
			// having overwritten the section's HTML
			if( notes ) {
				section.appendChild( notes );
			}

		} );

		return Promise.resolve();

	}

	function escapeForHTML( input ) {

	  return input.replace( /([&<>'"])/g, char => HTML_ESCAPE_MAP[char] );

	}

	return {
		id: 'markdown',

		/**
		 * Starts processing and converting Markdown within the
		 * current reveal.js deck.
		 */
		init: function( reveal ) {

			deck = reveal;

			let { renderer, animateLists, ...markedOptions } = deck.getConfig().markdown || {};

			if( !renderer ) {
				renderer = new marked.Renderer();

				renderer.code = ( code, language ) => {

					// Off by default
<<<<<<< HEAD
=======
					let lineNumberOffset = '';
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
					let lineNumbers = '';

					// Users can opt in to show line numbers and highlight
					// specific lines.
					// ```javascript []        show line numbers
					// ```javascript [1,4-8]   highlights lines 1 and 4-8
<<<<<<< HEAD
					if( CODE_LINE_NUMBER_REGEX.test( language ) ) {
						lineNumbers = language.match( CODE_LINE_NUMBER_REGEX )[1].trim();
=======
					// optional line number offset:
					// ```javascript [25: 1,4-8]   start line numbering at 25,
					//                             highlights lines 1 (numbered as 25) and 4-8 (numbered as 28-32)
					if( CODE_LINE_NUMBER_REGEX.test( language ) ) {
						let lineNumberOffsetMatch =  language.match( CODE_LINE_NUMBER_REGEX )[2];
						if (lineNumberOffsetMatch){
							lineNumberOffset =  `data-ln-start-from="${lineNumberOffsetMatch.trim()}"`;
						}

						lineNumbers = language.match( CODE_LINE_NUMBER_REGEX )[3].trim();
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
						lineNumbers = `data-line-numbers="${lineNumbers}"`;
						language = language.replace( CODE_LINE_NUMBER_REGEX, '' ).trim();
					}

					// Escape before this gets injected into the DOM to
					// avoid having the HTML parser alter our code before
					// highlight.js is able to read it
					code = escapeForHTML( code );

<<<<<<< HEAD
					return `<pre><code ${lineNumbers} class="${language}">${code}</code></pre>`;
=======
					// return `<pre><code ${lineNumbers} class="${language}">${code}</code></pre>`;

					return `<pre><code ${lineNumbers} ${lineNumberOffset} class="${language}">${code}</code></pre>`;
>>>>>>> ff31673fed1ee9a7f37beddca696c43e8d51489c
				};
			}

			if( animateLists === true ) {
				renderer.listitem = text => `<li class="fragment">${text}</li>`;
			}

			marked.setOptions( {
				renderer,
				...markedOptions
			} );

			return processSlides( deck.getRevealElement() ).then( convertSlides );

		},

		// TODO: Do these belong in the API?
		processSlides: processSlides,
		convertSlides: convertSlides,
		slidify: slidify,
		marked: marked
	}

};

export default Plugin;
