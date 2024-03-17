import { Button } from 'antd';
import AccounHeader from "../AccounHeader"
import { Link,useNavigate } from 'react-router-dom'

const Header = () => {
    const navigate = useNavigate()
    const toHome = () => {
        navigate('/')
    }

    return (
        <div className="header">
            <div className='login'>
                <AccounHeader></AccounHeader>
            </div>

            <Link to="/">
                <Button className="home-button" size="large" >
                    home
                </Button>
            </Link>
        </div>
    )
}

export default Header