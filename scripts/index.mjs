import { readFile, writeFile } from 'fs/promises'

import centra from 'centra'
import pLimit from 'p-limit'
import { remark } from 'remark'
import remarkGfm from 'remark-gfm'
import { select, selectAll } from 'unist-util-select'

const baseurl = process.argv[2]
const inputFile = process.argv[3]
const outputFile = process.argv[4]

const selector = 'tableCell:first-child inlineCode'
const sortEntries = async tree => {
	const rows = select('table', tree)
	const header = rows.children.shift()

	rows.children.sort((first, second) =>
		select(selector, first).value
			.localeCompare(select(selector, second).value))

	rows.children.unshift(header)
	return tree
}

const makeUrl = link => link.url.startsWith('http') ? link.url : baseurl + link.url

const get404s = async tree => {
	const rows = select('table', tree)
	const links = selectAll('tableCell:first-child link', rows)
		.map(makeUrl)


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
			return link ? good.has(makeUrl(link)) : true
		})


	return tree
}

const main = async () => {
	const file = await readFile(inputFile, { encoding: 'utf-8' })
	const output = await remark()
		.use(remarkGfm)
		.use(() => get404s)
		.use(() => sortEntries)
		.process(file)

	await writeFile(outputFile, String(output))
}

main()
