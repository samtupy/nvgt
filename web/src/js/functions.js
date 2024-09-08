function convertdate(dateString)
{
// Convert date string into a valid ISO format (inserting colon in the timezone)
const validDateString = dateString.replace(/([+-]\d{2})(\d{2})$/, '$1:$2');
return validDateString;
}
function convertrdate(datestr)
{
var r=new Date(datestr);
if (!r) r = new Date(convertdate(datestr));
const options = {
weekday: "long", 
month: "long", 
day: "numeric",
year: "numeric"
};
const toptions = {
hour: "numeric",
minute: "numeric",
second: "numeric",
hour12: true
};
var final = r.toLocaleDateString("EN-US", options) + ", " + r.toLocaleTimeString("EN-US", toptions);
return final;
}