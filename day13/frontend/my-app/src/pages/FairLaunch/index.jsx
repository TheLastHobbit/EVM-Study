import { useEffect, useState } from 'react'
import { NetworkPlugin, ethers } from 'ethers';

import { createClient } from "@supabase/supabase-js";
const supabase = createClient("https://aogdarqrsnhmhxrmgqps.supabase.co", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvZ2RhcnFyc25obWh4cm1ncXBzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDY1MjI3NDMsImV4cCI6MjAyMjA5ODc0M30.Q-huYLGRe_skR9CZJaMGRqj8SQqDsYU9k01fakZOCXE");


function FairLaunch() {
    const [mingName,setMingName] = useState("");
    const [mingSymbol,setMingSymbol] = useState("");
    const [totalSupply,setTotalSupply] = useState(0);
    const [perMint,setPerMint] = useState(0);

    
    function createMing(){
        

    }
}