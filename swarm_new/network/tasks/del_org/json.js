var fs = require('fs');
argv = process.argv.slice(2);
org = argv[0]
config = argv[1]
out_file = argv[2]
config = require(config);
// removed the org from object 
delete config.channel_group.groups.Application.groups[`Org${org}MSP`];
data = JSON.stringify(config)
// dump this new json to a file
fs.writeFileSync(out_file, data , 'utf-8'); 
console.log(`Removed Org${org} from file`)
