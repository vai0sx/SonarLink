import React, { Component } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Container from 'react-bootstrap/Container';
import Welcome from './components/Welcome';
import SongRegistered from './components/SongRegistered';
import SongPurchased from './components/SongPurchased';
import SongPlayed from './components/SongPlayed';
import PlaylistCreated from './components/PlaylistCreated';
import PremiumSubscriptionPurchased from './components/PremiumSubscriptionPurchased';
import LicensePurchased from './components/LicencePurchased';

class App extends Component {
render() {
return (
<Router>
<Container>
<Welcome />
<Routes>
<Route path="/" element={<SongRegistered />} />
<Route path="/create-experience" element={<SongPurchased />} />
<Route path="/buy-ticket/:experienceId" element={<SongPlayed />} />
<Route path="/confirm-attendance/:experienceId" element={<PlaylistCreated />} />
<Route path="/withdraw/:experienceId" element={<PremiumSubscriptionPurchased />} />
<Route path="/transactions" element={<LicensePurchased />} />
</Routes>
</Container>
</Router>
);
}
}

export default App;
