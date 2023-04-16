import React, { useState } from "react";

const NavBar = () => {
  const [isNavExpanded, setIsNavExpanded] = useState(false);

  return(
    <header>
        <div>
            <a href="/">Pixel</a>
            <div>
                <img src="" alt="" onClick={()=>{
                    setIsNavExpanded(true)
                }}/>
            </div>
        </div>
    </header>
  )
};

export default NavBar;
