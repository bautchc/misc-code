'use strict';

import * as vscode from 'vscode'; // license: MIT
import * as path from 'path'; // license: MIT
import * as fs from 'fs'; // license: MIT

const ESCAPE_REGEX: string = '[^\u001B]*(?:\u001B[^\u001B]*\u001B[^\u001B]*)*';

export function activate(context: vscode.ExtensionContext): void {
	context.subscriptions.push(vscode.commands.registerCommand('sitelen-kasi.mu', () => {
		vscode.window.showInformationMessage('mu.');
	}));

	context.subscriptions.push(vscode.commands.registerCommand('sitelen-kasi.pali', async () => {
		await convertToPDF();
	}));
}

export function deactivate(): void {}

async function convertToPDF(): Promise<void> {
	vscode.window.showInformationMessage('Converting to PDF...');

	try {
		const editor: vscode.TextEditor | undefined = vscode.window.activeTextEditor;
		if (!editor) {
		  	vscode.window.showWarningMessage('No active editor.');
		  	return;
		}

		const mdFileName: string = editor.document.uri.fsPath;
		const ext: string = path.extname(mdFileName);
		if (!pathExists(mdFileName)) {
			if (editor.document.isUntitled) {
				vscode.window.showWarningMessage('Please save the file before conversion.');
				return;
			}
			vscode.window.showWarningMessage('Source file not found.');
			return;
		}

		const filename: string = mdFileName.replace(ext, '.pdf');
		const text: string = editor.document.getText();
		await convertToPdf(text, filename);
	} catch (error) {
		if (error instanceof Error) {
			vscode.window.showErrorMessage(error.message);
		} else {
			vscode.window.showErrorMessage("Unknown error.");
		}
	}
}


function pathExists(path: string): boolean {
	if (path.length === 0) { return false; }
	try {
	  fs.accessSync(path);
	  return true;
	} catch (error) {
	  return false;
	}
}

async function convertToPdf(content: string, outputPath: string): Promise<void> {
	content = mdToLatex(content);

	const tempPath: string = outputPath.replace('.pdf', '.tex');

	fs.writeFile(tempPath, content, 'utf-8', error => {
		if (error) {
			vscode.window.showErrorMessage(error.message);
			return;
		}
	});

	vscode.window.showInformationMessage('Conversion complete.');
}


function mdToLatex(content: string): string {
	const debugMode: boolean = true;

	// Clean metadata
	// Metadata is not used
	content = content.replace(/^[ \r\n]+{/, '{');
	content = chompMetadata(content);

	// Escape content inside of codeblocks
	content = codeblockEscape(content);

	// Block math
	content = content.replace(/^\$\$.*\$\$$/g, '\u001B$&\u001B');

	// Escape inline content
	content = inlineEscape(content);

	// Handle escaped content inside inline escapes
	content = internalEscape(content, '`');
	content = internalEscape(content, '\\$');

	// Handle escaped characters and words
	content = deepReplace(content, /\\([^a-zA-Z\-]|[a-zA-Z\-][a-zA-Z+<=>0-9\-]*)/, '\u001B$1\u001B');

	// Handle internal long groups
	content = deepReplace(content, /(pi) \(\(([^) ]+) ([^)]+)\)\) ?/, '$1-$2 (($3))');
	content = deepReplace(content, /\(\(([^ )]+)(?: ([^)]+))?\)\) ?/, '$1_ (($2))');
	content = deepReplace(content, /\(\(\)\)/, '');
	// 3rd+ nested group not supported
	content = deepReplace(content, /\(\(\(+|\)\)\)+/, '');

	// Convert non-nimi
	content = convertPrelongs(content);
	content = convertPuncts(content);
	content = convertPostLongs(content);

	const wordConversions: Map<string, string> = readCSV('nimi_unicode.csv');

	// Handle unsupported nimi variations
	if (!debugMode) {
		content = normalizeInvalidVariations(content, wordConversions);
		content = splitUnsupportedCombinations(content, wordConversions);
	}

	// Convert words to unicode
	content = convertNimi(content, wordConversions);

	// Variable long character
	// TODO

	// Image
	content = addImages(content);

	// Remove unsupported custom spans
	content = deepReplace(content, /{([^}])}(?:{[^}]})*/, '$1');

	// Typeset cartouche
	content = typesetCartouche(content);

	// Convert undirected quotes to directional quotes
	content = deepReplace(content, /"([^"]*)" ?/, '\u{201C}$1\u{201D}');

	// Typeset long characters
	content = deepReplace(content, /\((.*?)\) ?/, '\u{F1997}\\dunderline{0.1em}{$1}\u{F1998}');

	// Chomp spaces from around $$
	content = deepReplace(content, /(?<![.:󱦜󱦝]) (\u001B\$.*?\$\u001B)/, '$1');
	content = deepReplace(content, /(\u001B\$.*?\$\u001B) /, '$1');

	// HRule
	content = content.replace(/^---+ *$/g, '\\hline');

	// Title page
	content = typesetTitlePage(content);

	// Handle chapter headers
	content = content.replace(/^## (.*)/gm, '\\chapter{$1}');

	// Typeset codeblocks
	content = typesetCodeblock(content);

	// Typeset inline code
	content = typesetInlineCode(content);

	// Typeset math
	content = deepReplace(content, /\u001B\$([^$]+)\$\u001B/, '\\raisebox{0.25em}{\\scalebox{0.85}{$\\,$1\\,$}}');

	// Remove escape characters
	content = content.replace(/\u001B/g, '');

	return content + '\n\\end{document}';
}

function deepReplace(string: string, regex: RegExp, replace: string): string {
	// Fails to match if there is an odd number of escape characters on either side. Since escape characters always
	// appear in pairs that surround what they're escaping, an odd number of escape characters on either side of a
	// substring indicates the substring is surrounded by escape characters and should not be parsed.
	regex = new RegExp(`^(${ESCAPE_REGEX})${regex.source}(${ESCAPE_REGEX})$`, 'm');
	// Add one to each capture group number to make room for an additional capture group
	for (let i = 7; i >= 1; --i) { replace = replace.replace(`$${i}`, `$${i + 1}`); }
	// Add a capture group to the start and a capture group to the end such that the last capture group is one higher
	// than the highest capture group present.
	// Note: cannot handle $s that are escaped to prevent forming capture group signifiers, but this does not occur in
	// the program.
	replace = '$1' +
						replace +
						'$' +
						Math.max(...((replace.match(/(?<=\$)\d/g) || ['1']).map((capture: string) => +capture + 1)));
	while (string.match(regex)) {
		string = string.replace(regex, replace);
	}
	return string;
}

function escapeRegex(string: string): string {
	return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function internalEscape(content: string, delim1: string, delim2 = '') {
	if (!delim2) { delim2 = delim1; }

	for (
		const match of content.matchAll(
			new RegExp(`\u001B${delim1}(?:[${delim2}]|${delim2}(?!\u001B))*${delim2}\u001B`, 'gm')
		)
	) {
		let matchCopy = match[0];
		for (const innerMatch of matchCopy.matchAll(new RegExp(/\\\\+/.source + delim2))) {
			matchCopy = matchCopy.replace(
				innerMatch[0],
				'\\'.repeat((innerMatch[0].length - 1) / 2) + `\u001B\u001B${delim2.slice(-1)}`
			);
		}
		content = content.replace(match[0], matchCopy);
	}

	return content;
}

function inlineEscape(content: string): string {
	for (
		const line of content.split('\n')
												 .map((line: string) => line.replace(/\r/, ''))
												 .filter(
													 (line: string) => line.charAt(0) !== '\u001B'
												 )
	) {
		const escapePoints: number[] = [];
		let escapeChar: string = '';
		let backSlashes: number = 0;
		for (let i: number = 0; i < line.length; ++i) {
			if (line.charAt(i) === '\\') {
				++backSlashes;
			} else {
				if (!escapeChar) {
					if (!(backSlashes % 2) && (line.charAt(i) === '`' || line.charAt(i) === '$')) {
						escapePoints.push(i + escapePoints.length);
						escapeChar = line.charAt(i);
					}
				} else if (line.charAt(i) === escapeChar && !(backSlashes % 2)) {
					escapePoints.push(i + escapePoints.length + 1);
					escapeChar = '';
				}
				backSlashes = 0;
			}
		}

		content = content.replace(
			new RegExp(`^${escapeRegex(line)}$`, 'm'),
			escapePoints.reduce(
				(newLine: string, index: number) => newLine.slice(0, index) + '\u001B' + newLine.slice(index),
				line
			)
		);
	}

	return content;
}

function codeblockEscape(content: string): string {
	for (const codeblock of content.matchAll(/^(:::+)(?:[^ ]* )*code .*?$(.*?)^\1 *$/gms)) {
		content = content.replace(codeblock[0], codeblock[0].replace(/^.+$/gm, '\u001B$&\u001B'));
	}
	return content;
}

function convertPrelongs(content: string): string {
	const preLong: Map<string, string> = new Map();
	preLong.set('kepeken', '󰀙');
	preLong.set('tawa', '󰁩');
	preLong.set('lon', '󰀬');
	preLong.set('tan', '󰁧');
	preLong.set('pi', '󱦓');

	for (const [word, unicode] of preLong) {
		content = deepReplace(content, new RegExp(`(?<![a-zA-Z+\\-])${word} ?\\(`), `${unicode}(`);
	}

	return content;
}

function convertPuncts(content: string): string {
	const puncts: Map<RegExp, string> = new Map();
	puncts.set(/\./, '󱦜');

	for (const [word, unicode] of puncts) {
		content = deepReplace(content, word, unicode);
	}

	return content;
}

function convertPostLongs(content: string): string {
	const postLong: Map<string, string> = new Map();
	postLong.set('\\) ?la' , ')󰀡');
	postLong.set('\\(ala' , '(󰤂');

	for (const [word, unicode] of postLong) {
		content = deepReplace(content, new RegExp(`${word}(?![a-zA-Z<=>+\\-]) ?`), unicode);
	}

	return content;
}

function normalizeInvalidVariations(content: string, wordConversions: Map<string, string>): string {
	// only normalize if the base is a valid nimi
	for (const word of content.matchAll(/([a-zA-Z]+)(?:[<=>]|\d+)/g) || []) {
		if (!wordConversions.has(word[0]) && wordConversions.has(word[1])) {
			content = deepReplace(content, new RegExp(word[0]), word[1]);
		}
	}

	return content;
}

function splitUnsupportedCombinations(content: string, wordConversions: Map<string, string>): string {
	for (const word of content.match(/[a-zA-Z0-9<=>+\-]+/g) || []) {
		// only split if the subwords are valid nimi
		if (
			!wordConversions.has(word) &&
			word.split(/[<=>+\-]+/)
					.filter((subword: string): boolean => subword !== '')
					.reduce((isMatch: boolean, subword: string): boolean => (isMatch && wordConversions.has(subword)), true)
		) {
			content = deepReplace(content, new RegExp(word), word.replace(/^[+\-]+|[+\-]$/, '').replace(/[+\-]/, ' '));
		}
	}

	return content;
}

function convertNimi(content: string, wordConversions: Map<string, string>): string {
	for (const [word, unicode] of wordConversions) {
		content = deepReplace(content, new RegExp(`(?<![a-zA-Z+\\-])${word}(?![a-zA-Z<=>+\\-]) ?`), unicode);
	}

	return content;
}

function typesetCartouche(content: string): string {
	const escapedCartoucheRegex: RegExp = new RegExp(
		`^${ESCAPE_REGEX}${/(\[([^\]]*)\] ?)/.source}${ESCAPE_REGEX}$`,
		'gm'
	);
	while (content.match(escapedCartoucheRegex)) {
		for (let match of content.matchAll(escapedCartoucheRegex)) {
			content = content.replace(
				match[0],
				match[0].replace(match[1], `\u{F1990}\\dunderline{0.1em}{\\textoverline{0.1em}{${match[2]}}}\u{F1991}`)
			);
		}
	}

	return content;
}

function typesetTitlePage(content: string): string {
	const prepend: string = `\\documentclass[letterpaper, openany]{book}

	\\usepackage[margin=1in]{geometry}
	\\usepackage{fontspec}
	\\usepackage{titletoc}
	\\usepackage{titlesec}
	\\usepackage{graphicx}
	\\usepackage{wrapfig}
	\\usepackage{float}

	\\setmainfont{nasin-nanpa}
	\\setlength{\\parskip}{10pt}
	\\setlength{\\parindent}{0pt}
	\\renewcommand{\\contentsname}{\u{F191F}\u{F1993}\\dunderline{0.1em}{\u{F1F2A}}\u{F1998}}
	\\titleformat{\\chapter}[display]{\\normalfont\\bfseries}{}{0pt}{\\Huge}
	\\renewcommand\\chaptermark[1]{\\markboth{#1}{}}

	\\newcommand\\dunderline[3][-0.1em]{{\\sbox0{#3}\\ooalign{\\copy0\\cr\\rule[\\dimexpr#1-#2\\relax]{\\wd0}{#2}}}}
	\\newcommand\\textoverline[3][1em]{{\\sbox0{#3}\\ooalign{\\copy0\\cr\\rule[\\dimexpr#1-#2\\relax]{\\wd0}{#2}}}}
	\\newcommand{\\thickhrulefill}{\\vspace{-1.5em}\\leavevmode\\leaders\\hrule height 1pt\\hfill\\kern 0pt}

	\\begin{document}
	\\sloppy
	\\raggedright
	\\frontmatter

	\\thispagestyle{empty}
	\\begin{center}
	 \\vspace*{2cm}
	 {\\Huge\\bfseries `;

	const endHeader: string = `\\par}
	\\end{center}
	\\newpage

	\\thispagestyle{empty}
	\\begin{center}
		\\vspace{2cm}`;

	const endTitlePage: string = `\\end{center}
	\\newpage

	\\titlecontents{chapter}[0pt]{\\addvspace{1em}}{}{}{\\titlerule*[1pc]{.}\\contentspage}
	\\tableofcontents
	\\mainmatter`;

	// Handle title page
	content = content.replace(/^# (.*)/m, `${prepend}$1${endHeader}`);
	content = content.replace(/^(## )/m, `${endTitlePage}\n$1`);

	return content;
}

function typesetCodeblock(content: string): string {
	for (let codeblock of content.matchAll(/^\u001B(:::+)(?:[^ ]* )*code .*?\u001B$(.*?)^\u001B\1 *\u001B$/gms)) {
		content = content.replace(
			codeblock[0],
			'\\thickhrulefill\n{\\setlength{\\parskip}{0pt}' +
				codeblock[2].replace(/[ #_{}]/g, '\\$&')
										.replace(/(\r?\n){2}/, '\n\\vspace{1em}\n') +
				'}\\thickhrulefill'
		);
	}

	return content;
}

function typesetInlineCode(content: string): string {
	const inlineCodeRegex: RegExp = new RegExp(ESCAPE_REGEX + '\u001B(`(.*?)`)\u001B' + ESCAPE_REGEX, 'gm');
	while (content.match(inlineCodeRegex)) {
		for (let match of content.matchAll(inlineCodeRegex)) {
			content = content.replace(
				match[1],
				`\\raisebox{0.15em}{\\scalebox{0.6}{${match[2].replace(/[#_{}]/g, '\\$&')}}}`
			);
		}
	}

	return content;
}

function chompMetadata(content: string): string {
	content = content.replace(/^[ \r\n]+{/, '{');
	if (content[0] === '{') {
		let nesting: number = 1;
		let i: number = 1;
		let inString: boolean = false;
		let slashes: number = 0;
		while (nesting > 0) {
			if (inString) {
				if (content[i] === '\\') {
					++slashes;
				} else {
					if (content[i] === '"' && !(slashes % 2)) { inString = false; }
					slashes = 0;
				}
			} else {
				switch (content[i]) {
					case '{':
						++nesting;
						break;
					case '}':
						--nesting;
						break;
					case '"':
						inString = true;
				}
			}
			++i;
		}
		content = content.slice(i);
	}
	return content;
}

function addImages(content: string): string {
	const nonCBrackStr: string = '(?:[^}]|\u001B}\u001B)*';

	for (
		const match of content.matchAll(
			new RegExp(
				`^{(${nonCBrackStr})}{((?:${nonCBrackStr} )?img(?: ${nonCBrackStr})?)} *$(?:[\r\n]^{(${nonCBrackStr})}{((?:` +
					`${nonCBrackStr} )?caption(?: ${nonCBrackStr})?)} *$)?`,
				'gm'
			)
		)
	) {
		const tags: string[] = match[2].split(' ');
		const width: string = (
			(tags.filter(tag => tag.match(/^width-/)) || [''])[0].match(/^width-(.*)$/) || ['', '0.3']
		)[1];
		const floatTags: string[] = tags.filter(tag => tag === 'float-left' || tag === 'float-right');
		let head: string;
		let tail: string;
		if (floatTags) {
			head = `\\begin{wrapfigure}{${floatTags[0][6]}}{${width}\\textwidth}`;
			tail = '\\end{wrapfigure}';
		} else {
			head = '\\begin{figure}[H]';
			tail = '\\end{figure}';
		}
		const template: string = `${head}
			\\centering
			\\includegraphics[width=${width}\\textwidth]{${match[1]}}
			${match[3] ? `\\caption{${match[3]}}` : ''}
			${tail}`;

		content = content.replace(match[0], template);
	}

	return content;
}

function readCSV(fileName: string): Map<string, string> {
	return fs.readFileSync(path.join(__dirname, '..', 'resources', fileName), 'utf8')
			     .split('\n')
					 .filter(row => row.length > 0)
					 .map(row => row.split(','))
					 .reduce(
						(map, row) => {
							map.set(row[0], row[1].replace(/"([^"]*)"/, '$1'));
							return map;
						},
						new Map()
					 );
}
