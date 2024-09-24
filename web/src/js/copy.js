//Js script that allows you to have the ability to copy code blocks.
document.querySelectorAll("pre").forEach(pre =>
{
const codeBlock = pre.querySelector("code"); // Check if <code> exists inside <pre>
// Get the content (if there"s <code>, use it; otherwise, fallback to <pre>)
const codeContent = codeBlock ? codeBlock.textContent : pre.textContent;
// Create a container to hold the language label, button, and the code block
const container = document.createElement("div");
// Extract the language from <pre>"s data-lang or <code>"s class
let language = pre.getAttribute("data-lang");
if (!language && codeBlock && codeBlock.className)
{
const match = codeBlock.className.match(/language-(\w+)/);
language = match ? match[1] : "";
}
// If language is found, create and insert a language label
if (language)
{
const langLabel = document.createElement("span");
langLabel.textContent = `${language} `;
container.appendChild(langLabel); // Add language label before the button
}
// Create the copy button
const copyButton = document.createElement("button");
const copy_text="Copy "+(language?language+" ":"")+"code to clipboard";
copyButton.textContent = copy_text;
container.appendChild(copyButton); // Add the button to the container
// Insert the container before the <pre> tag
pre.parentNode.insertBefore(container, pre);
container.appendChild(pre); // Add the pre inside the container
// Copy functionality
copyButton.addEventListener("click", () => {
navigator.clipboard.writeText(codeContent)
.then(() =>
{
copyButton.textContent = "Copied!";
setTimeout(() => {
copyButton.textContent = copy_text;
}, 1500);
})
.catch(err =>
{
console.error("Failed to copy: ", err);
});
});
});