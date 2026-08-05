export default function Footer() {
  const year = new Date().getFullYear()

  return (
    <footer className="border-t border-glass/[0.08] py-12 px-6">
      <div className="max-w-6xl mx-auto">
        <div className="grid md:grid-cols-4 gap-10 mb-10">
          <div>
            <h3 className="text-headline-md font-display text-primary-container mb-4">
              OmniLink
            </h3>
            <p className="text-body-md text-on-surface-variant">
              Your universal cloud clipboard and data pipeline
            </p>
          </div>

          <div>
            <h4 className="text-label-md font-mono text-on-surface mb-3 uppercase tracking-wider">
              Product
            </h4>
            <ul className="space-y-2">
              {['Features', 'Pricing', 'Download'].map((item) => (
                <li key={item}>
                  <a
                    href="#"
                    className="text-body-md text-on-surface-variant hover:text-primary transition-colors"
                  >
                    {item}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-label-md font-mono text-on-surface mb-3 uppercase tracking-wider">
              Resources
            </h4>
            <ul className="space-y-2">
              {['Help Center', 'Tutorials', 'Community'].map((item) => (
                <li key={item}>
                  <a
                    href="#"
                    className="text-body-md text-on-surface-variant hover:text-primary transition-colors"
                  >
                    {item}
                  </a>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="text-label-md font-mono text-on-surface mb-3 uppercase tracking-wider">
              Company
            </h4>
            <ul className="space-y-2">
              {['About', 'Privacy', 'Terms'].map((item) => (
                <li key={item}>
                  <a
                    href="#"
                    className="text-body-md text-on-surface-variant hover:text-primary transition-colors"
                  >
                    {item}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>

        <div className="border-t border-glass/[0.08] pt-6 text-center">
          <p className="text-body-md text-on-surface-variant">
            © {year} OmniLink. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  )
}
