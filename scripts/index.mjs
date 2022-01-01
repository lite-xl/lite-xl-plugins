import { readFile, writeFile } from 'fs/promises'

import centra from 'centra'
import pLimit from 'p-limit'
import { remark } from 'remark'
import remarkGfm from 'remark-gfm'
import strip from 'strip-markdown'
import { select, selectAll } from 'unist-util-select'

const configFile = process.argv[2]

const clone = obj => JSON.parse(JSON.stringify(obj))

const selector = 'tableCell:first-child inlineCode'
const sortEntries = () => async tree => {
	const rows = select('table', tree)
	const header = rows.children.shift()

	rows.children.sort((first, second) =>
		select(selector, first).value
			.localeCompare(select(selector, second).value))

	rows.children.unshift(header)
	return tree
}

const makeUrl = baseUrl => link => link.url.startsWith('http') ? link.url : baseUrl + link.url

const get404s = baseUrl => async tree => {
	const url = makeUrl(baseUrl)
	const rows = select('table', tree)
	const links = selectAll('tableCell:first-child link', rows)
		.map(url)


	const limit = pLimit(5)
	const reqs = links
		.map(url => 
			limit(() => centra(url, 'HEAD')
				.send()
				.then(res => [url, res.statusCode])
				.catch(() => [url, undefined])))
	
	const status = await Promise.all(reqs)
	const good = new Set(status.filter(([_, s]) => typeof s === 'number' && s < 400).map(([url]) => url))

	if (good.size !== status.length) {
		console.log(`Found ${status.length - good.size} broken URLs`)
		status
			.filter(([url]) => !good.has(url))
			.forEach(([url, status]) => console.log(`${url} : ${typeof status === 'number' ? status : 'failed'}`))
	}

	// filter the table
	rows.children = rows.children
		.filter(row => {
			const link = select('tableCell:first-child link', row)
			return link ? good.has(url(link)) : true
		})


	return tree
}

const stripMd = strip({ keep: ['tableCell'] })
const exportData = options => async tree => {
	const { baseUrl, output } = options
	const url = makeUrl(baseUrl)
	const rows = selectAll('table tableRow', tree)
	rows.shift()

	const md = remark().use(remarkGfm)
	for (const row of rows) {
		const nameCol = select('tableCell:first-child', row)
		const descCol = select('tableCell:nth-child(2)', row)

		// we actually need to clone because strip alters AST
		const name = stripMd(clone(nameCol)).children[0].value
		const desc = stripMd(clone(descCol)).children[0].value

		const realName = name.replace(/\*$/, '')
		output[realName] = {
			name: realName,
			external: name.endsWith('*'),
			description: desc,
			rawDescription: md.stringify(descCol),
			url: url(select('link', nameCol))
		}
	}
}

const main = async () => {
	const config = JSON.parse(await readFile(configFile, { encoding: 'utf-8' }))
	const {
		baseUrl,
		inputFile,
		outputFile,
		pluginFile
	} = config

	const file = await readFile(inputFile, { encoding: 'utf-8' })
	const plugins = {}
	const output = await remark()
		.use(remarkGfm)
		.use(get404s, baseUrl)
		.use(sortEntries)
		.use(exportData, { baseUrl, output: plugins })
		.process(file)

	await writeFile(outputFile, String(output))
	await writeFile(pluginFile, JSON.stringify(plugins))
}

main()
