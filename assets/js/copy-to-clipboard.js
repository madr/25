export default () => {
  const codeblocks = document.querySelectorAll("pre>code");

  for (const b of codeblocks) {
    const button = document.createElement("button");
    button.innerHTML = "Kopiera";
    button.addEventListener("click", function ({target}) {
      const text = target.previousSibling.innerHTML;
      navigator.clipboard.writeText(text);
    })
    b.parentNode.appendChild(button);
  }
}

