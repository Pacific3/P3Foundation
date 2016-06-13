
extension String {
    public func matches(pattern: Match) -> Bool {
        return pattern.validate(feed: self)
    }
}
