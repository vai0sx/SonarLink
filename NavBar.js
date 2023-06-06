import React from 'react';
import { Link } from 'react-router-dom';
import { Navbar, Nav } from 'react-bootstrap';

const AppNavbar = () => {
  return (
    <Navbar bg="light" expand="lg">
      <Navbar.Brand as={Link} to="/">SonarLink</Navbar.Brand>
      <Navbar.Toggle aria-controls="basic-navbar-nav" />
      <Navbar.Collapse id="basic-navbar-nav">
        <Nav className="mr-auto">
          <Nav.Link as={Link} to="/song-registered">SongRegistered</Nav.Link>
          <Nav.Link as={Link} to="/buy-ticket">Comprar ticket</Nav.Link>
          <Nav.Link as={Link} to="/confirm-attendance">Confirmar asistencia</Nav.Link>
          <Nav.Link as={Link} to="/withdraw-funds">Retirar fondos</Nav.Link>
          <Nav.Link as={Link} to="/wallet">Billetera</Nav.Link>
        </Nav>
      </Navbar.Collapse>
    </Navbar>
  );
};

export default AppNavbar;
