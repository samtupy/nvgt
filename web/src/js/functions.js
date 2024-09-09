function normalize_iso_datetime(dateString) {
	// Convert date string into a valid ISO format (inserting colon in the timezone)
	const validDateString = dateString.replace(/([+-]\d{2})(\d{2})$/, '$1:$2');
	return validDateString;
}
function local_datetime_string(date_input) {
	var r=new Date(date_input);
	if (!r) r = new Date(normalize_iso_datetime(date_input));
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
		hour12: true,
		timeZoneName: "short"
	};
	var final = r.toLocaleDateString("EN-US", options) + " at " + r.toLocaleTimeString("EN-US", toptions);
	return final;
}
