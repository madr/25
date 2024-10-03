export const copyCodeToClipboard = () => {
  const codeblocks = document.querySelectorAll("pre>code");
  for (const b of codeblocks) {
    const button = document.createElement("button");
    button.innerHTML = "Kopiera";
    button.addEventListener("click", function ({ target }) {
      const text = target.previousSibling.innerHTML;
      navigator.clipboard.writeText(text);
    });
    b.parentNode.appendChild(button);
  }
};

export const copyUrlToClipboard = () => {
  const permalinks = document.querySelectorAll(".permalink");
  for (const pl of permalinks) {
    pl.setAttribute(
      "title",
      pl.getAttribute("title") + ", klicka för att kopiera",
    );
    pl.addEventListener("click", function (evt) {
      const { target, shiftKey, ctrlKey, altKey } = evt;
      if (!shiftKey && !ctrlKey && !altKey) {
        evt.preventDefault();
        const text = target.href;
        navigator.clipboard.writeText(text);
      }
    });
  }
};
